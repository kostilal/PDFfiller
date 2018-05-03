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
            let axis: ShapeAxis = i % 2 == 0 ? .horizontal : .vertical
            
            let ellipseShape = EllipseShape()
            ellipseShape.centerPoint = midPoint
            ellipseShape.angle = angle
            ellipseShape.axis = axis
            layer.addSublayer(ellipseShape)
            ellipseShapes.append(ellipseShape)
            
            let shapeCorrespondenceTable = ShapesCorrespondenceTable(ellipseIndex: i, circleIndexes: [i, nextIndex])
            correspondenceTable.append(shapeCorrespondenceTable)
        }
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
    
    func lineContains(point: CGPoint, line: Line) -> Bool {
        print("Dstans A+C+B+C : \(round(findDistanceBetween(point: line.pointA, point: point) + findDistanceBetween(point: line.pointB, point: point)))")
        print("DIstans A+B : \(round(findDistanceBetween(point: line.pointA, point: line.pointB)))")
        
        
        return round(findDistanceBetween(point: line.pointA, point: point) + findDistanceBetween(point: line.pointB, point: point)) == round(findDistanceBetween(point: line.pointA, point: line.pointB))
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
            if !validateDraging(circle: circle) {
                return
            }
            dragCircleShape(circle, point)
        } else if let ellipse = dragableShape as? EllipseShape {
            dragEllipseShape(ellipse, point)
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
                let distance = abs(circle.centerPoint.y - point.y)
                let offset = circle.centerPoint.y > point.y  ? -distance : distance
                circle.centerPoint = CGPoint(x: circle.centerPoint.x, y: point.y + offset)
                
                print("point: \(point.y) ||| circleStartPoint: \(circle.centerPoint) ||| distance: \(distance) ||| offset: \(offset) ||| circleEndPoint: \(circle.centerPoint)")
            })
            
            shape.centerPoint = CGPoint(x: shape.centerPoint.x, y: point.y)
        } else {
            circlesIndexes?.forEach({ (index) in
                let circle = circleShapes[index]
                let distance = abs(circle.centerPoint.x - point.x)
                circle.centerPoint = CGPoint(x: point.x - distance, y: circle.centerPoint.y)
            })
            
            shape.centerPoint = CGPoint(x: point.x, y: shape.centerPoint.y)
        }
        
        redrawEllipseLayers()
        drawRectangleLayer()
    }
    
    func validate(shape: DragableShape, contain point: CGPoint) -> Bool {
        let frame = CGRect(x: cropedObjectFrame.origin.x,
                           y: cropedObjectFrame.origin.y,
                           width: cropedObjectFrame.size.width,
                           height: cropedObjectFrame.size.height)
        
        return frame.contains(point)
    }
    
    func validateDraging(circle: CircleShape) -> Bool {
        guard let shapeIndex = circleShapes.index(of: circle) else { return false }
        
        let pointA = circleShapes[(shapeIndex + 1 > circleShapes.count - 1) ? 0 : shapeIndex + 1].centerPoint
        let pointB = circleShapes[(shapeIndex - 1 < 0) ? circleShapes.count - 1 : shapeIndex - 1].centerPoint
        let line = Line(pointA: pointA, pointB: pointB)

        return !lineContains(point: circle.centerPoint, line: line)
    }
}
