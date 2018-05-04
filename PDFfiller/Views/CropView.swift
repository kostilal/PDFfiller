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

struct Line {
    var pointA: CGPoint
    var pointB: CGPoint
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
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touch = touches.first
        
        guard let point = touch?.location(in: self) else { return }
        guard let sublayers = layer.sublayers as? [CAShapeLayer] else { return }
        
        for layer in sublayers {
            if let path = layer.path, path.contains(point) {
                if let circle = circleShapes.first(where: {$0 == layer}) {
                    dragableShape = circle
                } else if let elipse = ellipseShapes.first(where: {$0 == layer}) {
                    dragableShape = elipse
                }
            }
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touch = touches.first
        
        guard let point = touch?.location(in: self) else { return }
        guard let dragableShape = dragableShape, validate(shape: dragableShape, contain: point) else { return }
        
        if let circle = dragableShape as? CircleShape {
            if !validateDraging(circle: circle, touchPoint: point) {
                return
            }
            CATransaction.begin()
            CATransaction.setDisableActions(true)
            dragCircleShape(circle, point)
            rotateEllipses(forCicle: circle)
            CATransaction.commit()
            
        } else if let ellipse = dragableShape as? EllipseShape {
            if !validateDraging(ellipse: ellipse, touchPoint: point) {
                return
            }
            CATransaction.begin()
            CATransaction.setDisableActions(true)
            dragEllipseShape(ellipse, point)
            circleShapes.forEach { (circle) in
                rotateEllipses(forCicle: circle)
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
        shape.centerPoint = point
        redrawEllipseLayers()
        drawRectangleLayer()
    }
    
    func dragEllipseShape(_ shape: EllipseShape, _ point: CGPoint) {
        let ellipseIndex = ellipseShapes.index(of: shape)
        let circlesIndexes = correspondenceTable.first(where: {$0.ellipseIndex == ellipseIndex})?.circleIndexes
        
        if shape.axis == .horizontal {
            circlesIndexes?.forEach({ (index) in
                let circle = circleShapes[index]
                let distance = abs(circle.centerPoint.x - point.x)
                let offset = circle.centerPoint.x > point.x  ? -distance : distance
                circle.centerPoint = CGPoint(x: point.x + offset, y: circle.centerPoint.y)
            })
            
            shape.centerPoint = CGPoint(x: point.x, y: shape.centerPoint.y)
        } else {
            circlesIndexes?.forEach({ (index) in
                let circle = circleShapes[index]
                let distance = abs(circle.centerPoint.y - point.y)
                let offset = circle.centerPoint.y > point.y  ? -distance : distance
                circle.centerPoint = CGPoint(x: circle.centerPoint.x, y: point.y + offset)
            })
            
            shape.centerPoint = CGPoint(x: shape.centerPoint.x, y: point.y)
        }
        
        redrawEllipseLayers()
        drawRectangleLayer()
    }
    
    func validate(shape: DragableShape, contain point: CGPoint) -> Bool {
        return cropedObjectFrame.contains(point)
    }
    
    func validateDraging(circle: CircleShape, touchPoint: CGPoint) -> Bool {
        guard let shapeIndex = circleShapes.index(of: circle) else { return false }
        
        let pointA = circleShapes[(shapeIndex - 1 < 0) ? circleShapes.count - 1 : shapeIndex - 1].centerPoint
        let pointB = touchPoint
        let pointC = circleShapes[(shapeIndex + 1 > circleShapes.count - 1) ? 0 : shapeIndex + 1].centerPoint
        let area = findArea(point: pointA, point: pointB, point: pointC)
        
        return area > 0
    }
    
    func validateDraging(ellipse: EllipseShape, touchPoint: CGPoint) -> Bool {
        let oppositeShape = ellipseShapes.first(where: {$0.axis == ellipse.axis && $0 != ellipse})
        
        guard let path = oppositeShape?.path else {
            return false
        }

        return !path.contains(touchPoint)
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
    
    func rotateEllipses(forCicle cicle: CircleShape) {
        
        switch cicle.positionType {
        case .topLeft:
            
            let topRightPoint = getCircleShapeCenterPoint(byPosition: .topRight)
            let topEllipseAngle = cicle.centerPoint.horizontalAngle(forPoint: topRightPoint)
            let topEllipse = getEllipseShape(byPosition: .top)
            topEllipse.angle = topEllipseAngle
            
            let bottomLeftPoint = getCircleShapeCenterPoint(byPosition: .bottomLeft)
            let leftEllipseAngle = cicle.centerPoint.horizontalAngle(forPoint: bottomLeftPoint)
            let leftEllipse = getEllipseShape(byPosition: .left)
            leftEllipse.angle = leftEllipseAngle
            
        case .topRight:
            let topLeftPoint = getCircleShapeCenterPoint(byPosition: .topLeft)
            let topEllipseAngle = cicle.centerPoint.horizontalAngle(forPoint: topLeftPoint)
            let topEllipse = getEllipseShape(byPosition: .top)
            topEllipse.angle = topEllipseAngle
            
            let bottomRightPoint = getCircleShapeCenterPoint(byPosition: .bottomRight)
            let rightEllipseAngle = cicle.centerPoint.horizontalAngle(forPoint: bottomRightPoint)
            let rightEllipse = getEllipseShape(byPosition: .right)
            rightEllipse.angle = rightEllipseAngle
            
          case .bottomLeft:
            let topLeftPoint = getCircleShapeCenterPoint(byPosition: .topLeft)
            let leftEllipseAngle = cicle.centerPoint.horizontalAngle(forPoint: topLeftPoint)
            let leftEllipse = getEllipseShape(byPosition: .left)
            leftEllipse.angle = leftEllipseAngle
            
            let bottomRightPoint = getCircleShapeCenterPoint(byPosition: .bottomRight)
            let bottomEllipseAngle = cicle.centerPoint.horizontalAngle(forPoint: bottomRightPoint)
            let bottomEllipse = getEllipseShape(byPosition: .bottom)
            bottomEllipse.angle = bottomEllipseAngle
            
        case .bottomRight:
            let topRightPoint = getCircleShapeCenterPoint(byPosition: .topRight)
            let rightEllipseAngle = cicle.centerPoint.horizontalAngle(forPoint: topRightPoint)
            let rightEllipse = getEllipseShape(byPosition: .right)
            rightEllipse.angle = rightEllipseAngle
            
            let bottomLeftPoint = getCircleShapeCenterPoint(byPosition: .bottomLeft)
            let bottomEllipseAngle = cicle.centerPoint.horizontalAngle(forPoint: bottomLeftPoint)
            let bottomEllipse = getEllipseShape(byPosition: .bottom)
            bottomEllipse.angle = bottomEllipseAngle
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
