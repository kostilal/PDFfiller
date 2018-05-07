//
//  CropView.swift
//  PDFfiller
//
//  Created by Костюкевич Илья on 30.04.2018.
//  Copyright © 2018 Ilya Kostyukevich. All rights reserved.
//

import UIKit
import CoreGraphics

struct ShapesCorrespondenceTable {
    var ellipseIndex: Int
    var circleIndexes: [Int]
}

extension BinaryInteger {
    var degreesToRadians: CGFloat { return CGFloat(Int(self)) * .pi / 180 }
}

protocol CropViewProtocol {
    var cropedObjectFrame: CGRect { get set }
    var shapePositions: [CGPoint]? { get set }
}

class CropView: UIView, CropViewProtocol {
    private var circleShapes = [CircleShape]()
    private var ellipseShapes = [EllipseShape]()
    private let rectangleShape = CAShapeLayer()
    private var initialPositions: [CGPoint]
    private var dragableShape: DragableShape?
    private var correspondenceTable = [ShapesCorrespondenceTable]()
    
    var cropedObjectFrame: CGRect
    var shapePositions: [CGPoint]?
    
    init(frame: CGRect, cropedObjectFrame: CGRect, shapePositions: [CGPoint]?) {
        self.cropedObjectFrame = cropedObjectFrame
        self.shapePositions = shapePositions
        self.initialPositions = CropView.calculateInitialPositions(cropedObjectFrame)
        
        super.init(frame: frame)
        
        defaultSetup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func defaultSetup() {
        backgroundColor = .clear
        isUserInteractionEnabled = true
        
        drawShapes()
    }
    
    private class func calculateInitialPositions(_ cropedObjectFrame: CGRect) -> [CGPoint] {
        return [CGPoint(x: cropedObjectFrame.origin.x, y: cropedObjectFrame.origin.y),
                CGPoint(x: cropedObjectFrame.origin.x + cropedObjectFrame.size.width, y: cropedObjectFrame.origin.y),
                CGPoint(x: cropedObjectFrame.origin.x + cropedObjectFrame.size.width, y: cropedObjectFrame.origin.y + cropedObjectFrame.size.height),
                CGPoint(x: cropedObjectFrame.origin.x, y: cropedObjectFrame.origin.y + cropedObjectFrame.size.height)]
    }
    
    //MARK: - Drawing
    open func drawShapes() {
        drawDragLayers()
        drawRectangleLayer()
    }
    
    open func redrawShapes(_ cropedObjectFrame: CGRect?) {
        if let cropedObjectFrame = cropedObjectFrame {
            self.cropedObjectFrame = cropedObjectFrame
            initialPositions = CropView.calculateInitialPositions(cropedObjectFrame)
        }
        
        redrawCirclesLayers()
        redrawEllipseLayers()
        drawRectangleLayer()
    }
    
    private func drawDragLayers() {
        let startPositions = shapePositions ?? initialPositions
        
        for i in 0..<startPositions.count {
            let circleShape = CircleShape()
            circleShape.centerPoint = startPositions[i]
            circleShape.backgroundColor = UIColor.yellow.cgColor
            layer.addSublayer(circleShape)
            circleShapes.append(circleShape)
            
            let nextIndex = i + 1 == startPositions.count ? 0 : i + 1
            let midPoint = findCeneterBetween(point: startPositions[i], andPoint: startPositions[nextIndex])
            let angle = i % 2 == 0 ? 0 : 90
            let axis: ShapeAxis = i % 2 == 0 ? .vertical : .horizontal
            
            let ellipseShape = EllipseShape()
            ellipseShape.centerPoint = midPoint
            ellipseShape.angle = angle.degreesToRadians
            ellipseShape.axis = axis
            layer.addSublayer(ellipseShape)
            ellipseShapes.append(ellipseShape)
            
            let shapeCorrespondenceTable = ShapesCorrespondenceTable(ellipseIndex: i, circleIndexes: [i, nextIndex])
            correspondenceTable.append(shapeCorrespondenceTable)
        }
        
        setCicleShapesPositionType()
        setEllipseShapesPositionType()
    }
    
    private func drawRectangleLayer() {
        let path = UIBezierPath()
        path.move(to: circleShapes.first!.centerPoint)
        
        for i in 1..<circleShapes.count {
            path.addLine(to: circleShapes[i].centerPoint)
        }
        
        path.close()
        
        rectangleShape.fillColor = UIColor(red: 0/255, green: 134/255, blue: 234/255, alpha: 0.4).cgColor
        rectangleShape.strokeColor = UIColor(red: 0/255, green: 134/255, blue: 234/255, alpha: 1).cgColor
        rectangleShape.path = path.cgPath
        layer.addSublayer(rectangleShape)
    }
    
    private func redrawEllipseLayers() {
        for i in 0..<circleShapes.count {
            let nextIndex = i + 1 == circleShapes.count ? 0 : i + 1
            let midPoint = findCeneterBetween(point: circleShapes[i].centerPoint, andPoint: circleShapes[nextIndex].centerPoint)
            ellipseShapes[i].centerPoint = midPoint
        }
    }
    
    private func redrawCirclesLayers() {
        let startPositions = shapePositions ?? initialPositions

        for (index, shape) in circleShapes.enumerated() {
            shape.centerPoint = startPositions[index]
        }
    }
  
    //MARK: - Touches & Dtraging
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touch = touches.first
        
        guard let point = touch?.location(in: self) else { return }
        guard let shapeSublayers = layer.sublayers as? [CAShapeLayer] else { return }
        
        for shapeLayer in shapeSublayers {
            if let path = shapeLayer.path, path.contains(point) {
                if let circle = circleShapes.first(where: {$0 == shapeLayer}) {
                    dragableShape = circle
                } else if let ellipse = ellipseShapes.first(where: {$0 == shapeLayer}) {
                    bring(sublayer: ellipse, toFront: self.layer)
                    dragableShape = ellipse
                }
            }
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touch = touches.first
        
        guard let point = touch?.location(in: self) else { return }
        guard let dragableShape = dragableShape, validate(shape: dragableShape, contain: point) else { return }
        
        if let circle = dragableShape as? CircleShape {
            CATransaction.begin()
            CATransaction.setDisableActions(true)
            
            dragCircleShape(circle, point)
            changeEllipseAngle(forChangedCorner: circle)
            
            CATransaction.commit()
            
        } else if let ellipse = dragableShape as? EllipseShape {
            CATransaction.begin()
            CATransaction.setDisableActions(true)
            
            dragEllipseShape(ellipse, point)
            circleShapes.forEach { (circle) in
                changeEllipseAngle(forChangedCorner: circle)
            }
            
            CATransaction.commit()
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        dragableShape = nil
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        dragableShape = nil
    }
    
    func dragCircleShape(_ shape: CircleShape, _ point: CGPoint) {
        
        if !isCornerAllowedMoving(toPoint: point, forLinePosition: shape.positionType) {
            return
        }
        
        shape.centerPoint = point
        redrawEllipseLayers()
        drawRectangleLayer()
    }
    
    func dragEllipseShape(_ ellipse: EllipseShape, _ point: CGPoint) {
        if !isLineAllowedMoving(toPoint: point, forLinePosition: ellipse.positionType) {
            return
        }
        
        let ellipseIndex = ellipseShapes.index(of: ellipse)
        let circlesIndexes = correspondenceTable.first(where: {$0.ellipseIndex == ellipseIndex})?.circleIndexes
        
        if ellipse.axis == .horizontal {
            circlesIndexes?.forEach({ (index) in
                let circle = circleShapes[index]
                circle.centerPoint = CGPoint(x: point.x, y: circle.centerPoint.y)
            })

            ellipse.centerPoint = CGPoint(x: ellipse.centerPoint.x, y: point.y)
        } else {
            circlesIndexes?.forEach({ (index) in
                let circle = circleShapes[index]
                circle.centerPoint = CGPoint(x: circle.centerPoint.x, y: point.y)
            })
            
            ellipse.centerPoint = CGPoint(x: point.x, y: ellipse.centerPoint.y)
        }
        
        redrawEllipseLayers()
        drawRectangleLayer()
    }
    
    func validate(shape: DragableShape, contain point: CGPoint) -> Bool {
        return cropedObjectFrame.contains(point)
    }
}
//MARK: - Helpers
private extension CropView {
    private func findCeneterBetween(point a: CGPoint, andPoint b: CGPoint) -> CGPoint {
        let x = (a.x + b.x) / 2
        let y = (a.y + b.y) / 2
        
        return CGPoint(x: x, y: y)
    }
    
    func findDistanceBetween(point a: CGPoint, point b: CGPoint) -> CGFloat {
        let xDist = a.x - b.x
        let yDist = a.y - b.y
        return CGFloat(sqrt((xDist * xDist) + (yDist * yDist)))
    }
    
    func findArea(point a: CGPoint, point b: CGPoint, point c: CGPoint) -> CGFloat {
        return ((a.x - b.x) * (a.y + b.y) + (b.x - c.x) * (b.y + c.y) + (c.x - a.x) * (c.y + a.y)) / 2.0
    }
}

private extension CropView {
    
    func setCicleShapesPositionType() {
        
        for (index, shape) in circleShapes.enumerated() {
            switch index {
                case 0:
                    shape.positionType = .topLeft
                case 1:
                    shape.positionType = .topRight
                case 2:
                    shape.positionType = .bottomRight
                case 3:
                    shape.positionType = .bottomLeft
                default:
                    break
            }
        }
    }
    
    func setEllipseShapesPositionType() {
        
        for (index, shape) in ellipseShapes.enumerated() {
            switch index {
            case 0:
                shape.positionType = .top
            case 1:
                shape.positionType = .right
            case 2:
                shape.positionType = .bottom
            case 3:
                shape.positionType = .left
            default:
                break
            }
        }
    }
    
    func changeEllipseAngle(forChangedCorner corner: CircleShape) {
        let cornerPoint = corner.centerPoint
        
        switch corner.positionType {
        case .topLeft:
            let topRightPoint = getCircleShapeCenterPoint(byPosition: .topRight)
            let topEllipse = getEllipseShape(byPosition: .top)
            let bottomLeftPoint = getCircleShapeCenterPoint(byPosition: .bottomLeft)
            let leftEllipse = getEllipseShape(byPosition: .left)
            
            topEllipse.positionAlongLine(withStartingPoint: cornerPoint, andSecond: topRightPoint)
            leftEllipse.positionAlongLine(withStartingPoint: cornerPoint, andSecond: bottomLeftPoint)
            
        case .topRight:
            let topLeftPoint = getCircleShapeCenterPoint(byPosition: .topLeft)
            let topEllipse = getEllipseShape(byPosition: .top)
            let bottomRightPoint = getCircleShapeCenterPoint(byPosition: .bottomRight)
            let rightEllipse = getEllipseShape(byPosition: .right)
            
            topEllipse.positionAlongLine(withStartingPoint: cornerPoint, andSecond: topLeftPoint)
            rightEllipse.positionAlongLine(withStartingPoint: cornerPoint, andSecond: bottomRightPoint)
            
          case .bottomLeft:
            let topLeftPoint = getCircleShapeCenterPoint(byPosition: .topLeft)
            let leftEllipse = getEllipseShape(byPosition: .left)
            let bottomRightPoint = getCircleShapeCenterPoint(byPosition: .bottomRight)
            let bottomEllipse = getEllipseShape(byPosition: .bottom)
            
            leftEllipse.positionAlongLine(withStartingPoint: cornerPoint, andSecond: topLeftPoint)
            bottomEllipse.positionAlongLine(withStartingPoint: cornerPoint, andSecond: bottomRightPoint)
            
        case .bottomRight:
            let topRightPoint = getCircleShapeCenterPoint(byPosition: .topRight)
            let rightEllipse = getEllipseShape(byPosition: .right)
            let bottomLeftPoint = getCircleShapeCenterPoint(byPosition: .bottomLeft)
            let bottomEllipse = getEllipseShape(byPosition: .bottom)
            
            rightEllipse.positionAlongLine(withStartingPoint: cornerPoint, andSecond: topRightPoint)
            bottomEllipse.positionAlongLine(withStartingPoint: cornerPoint, andSecond: bottomLeftPoint)
        }
    }
    
    func getCircleShapeCenterPoint(byPosition positionType: CircleShape.PositionType) -> CGPoint {
        if let shape = circleShapes.first(where: { $0.positionType == positionType }) {
            return shape.centerPoint
        }
        
        return CGPoint.zero
    }
    
    func getEllipseShape(byPosition positionType: EllipseShape.PositionType) -> EllipseShape {
        if let shape = ellipseShapes.first(where: { $0.positionType == positionType }) {
            return shape
        }
    
        return EllipseShape()
    }
}

//MARK: - Position Chnage Validation
private extension CropView {
    func isLineAllowedMoving(toPoint point: CGPoint, forLinePosition positionType: EllipseShape.PositionType) -> Bool {
        
        switch positionType {
            case .top:
                let bottomEllipse = getEllipseShape(byPosition: .bottom)
                return point.y <= bottomEllipse.centerPoint.y
            case .bottom:
                let topEllipse = getEllipseShape(byPosition: .top)
                return topEllipse.centerPoint.y <= point.y
            case .left:
                let rightEllipse = getEllipseShape(byPosition: .right)
                return point.x <= rightEllipse.centerPoint.x
            case .right:
                let leftEllipse = getEllipseShape(byPosition: .left)
                return leftEllipse.centerPoint.x <= point.x
        }
    }
    
    func isCornerAllowedMoving(toPoint point: CGPoint, forLinePosition positionType:  CircleShape.PositionType) -> Bool {
        
        switch positionType {
            case .topLeft:
                let topRight = getCircleShapeCenterPoint(byPosition: .topRight)
                let bottomLeft = getCircleShapeCenterPoint(byPosition: .bottomLeft)
                let closestPoint = point.closestPointOnLineSegment(startPoint: bottomLeft, endPoint: topRight)
                
                return point <= closestPoint
            case .topRight:
                let topLeft = getCircleShapeCenterPoint(byPosition: .topLeft)
                let bottomRight = getCircleShapeCenterPoint(byPosition: .bottomRight)
                let closestPoint = point.closestPointOnLineSegment(startPoint: topLeft, endPoint: bottomRight)
                
                return point.y <= closestPoint.y
            case .bottomLeft:
                let topLeft = getCircleShapeCenterPoint(byPosition: .topLeft)
                let bottomRight = getCircleShapeCenterPoint(byPosition: .bottomRight)
                let closestPoint = point.closestPointOnLineSegment(startPoint: topLeft, endPoint: bottomRight)
   
                return point.x <= closestPoint.x
            case .bottomRight:
                let topRight = getCircleShapeCenterPoint(byPosition: .topRight)
                let bottomLeft = getCircleShapeCenterPoint(byPosition: .bottomLeft)
                let closestPoint = point.closestPointOnLineSegment(startPoint: bottomLeft, endPoint: topRight)
    
                return point >= closestPoint
        }
    }
    
    func bring(sublayer shapeLayer: CAShapeLayer, toFront front: CALayer) {
        shapeLayer.removeFromSuperlayer()
        front.addSublayer(shapeLayer)
    }
}
