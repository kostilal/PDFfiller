//
//  CropView.swift
//  PDFfiller
//
//  Created by Костюкевич Илья on 30.04.2018.
//  Copyright © 2018 Ilya Kostyukevich. All rights reserved.
//

import UIKit
import QuartzCore

extension BinaryInteger {
    var degreesToRadians: CGFloat { return CGFloat(Int(self)) * .pi / 180 }
}

extension CropView {
    
}

protocol CropViewProtocol {
    var positions: [CGPoint]? { get set }
}

class CropView: UIView, CropViewProtocol {
    private var circleShapes = [CircleShape]()
    private var ellipseShapes = [EllipseShape]()
    private let rectangleShape = CAShapeLayer()
    
    var positions: [CGPoint]?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        defaultSetup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        defaultSetup()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        drawDragLayers()
        drawRectangleLayer()
    }
    
    private func defaultSetup() {
        backgroundColor = .clear
        isUserInteractionEnabled = true
    }
    
    func drawDragLayers() {
        let initialPositions = positions ?? [CGPoint(x: bounds.origin.x, y: bounds.origin.y),
                                             CGPoint(x: bounds.origin.x + bounds.size.width, y: bounds.origin.y),
                                             CGPoint(x: bounds.size.width, y: bounds.size.height),
                                             CGPoint(x: bounds.origin.x, y: bounds.size.height)]
        
        for i in 0..<initialPositions.count {
            let circleShape = CircleShape(centerPoint: initialPositions[i])
            
            layer.addSublayer(circleShape)
            circleShapes.append(circleShape)
            
            let nextIndex = i + 1 == initialPositions.count ? 0 : i + 1
            let midPoint = findCeneterBetween(point: initialPositions[i], andPoint: initialPositions[nextIndex])
            let ellipseShape = EllipseShape(centerPoint: midPoint, angle: i % 2 == 0 ? 0 : 90)
            
            layer.addSublayer(ellipseShape)
            ellipseShapes.append(ellipseShape)
        }
    }
    
    func drawRectangleLayer() {
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
    
    func redrawEllipseLayers() {
        for i in 0..<circleShapes.count {
            let nextIndex = i + 1 == circleShapes.count ? 0 : i + 1
            let midPoint = findCeneterBetween(point: circleShapes[i].centerPoint, andPoint: circleShapes[nextIndex].centerPoint)
            ellipseShapes[i].centerPoint = midPoint
        }
    }
    
    func findCeneterBetween(point a: CGPoint, andPoint b: CGPoint) -> CGPoint {
        let x = (a.x + b.x) / 2
        let y = (a.y + b.y) / 2
        
        return CGPoint(x: x, y: y)
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touch = touches.first
        
        guard let point = touch?.location(in: self) else { return }
        guard let sublayers = layer.sublayers as? [CAShapeLayer] else { return }
        
        for layer in sublayers {
            if let path = layer.path, path.contains(point) {
                guard let circle = layer as? CircleShape, let pos = touch?.location(in: self) else {
                    return
                }
                
                circle.centerPoint = pos
                drawRectangleLayer()
                redrawEllipseLayers()
            }
        }
    }
}
