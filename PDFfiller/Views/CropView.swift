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

protocol CropViewProtocol {
    var positions: [CGPoint]? { get set }
}

class CropView: UIView, CropViewProtocol {
    private var circleShapes = [CAShapeLayer]()
    private var centerShapes = [CAShapeLayer]()
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
        setupDragLayers()
    }
    
    private func defaultSetup() {
        backgroundColor = .clear
    }
    
    func setupDragLayers() {
        let initialPositions = positions ?? [CGPoint(x: bounds.origin.x, y: bounds.origin.y),
                                             CGPoint(x: bounds.origin.x + bounds.size.width, y: bounds.origin.y),
                                             CGPoint(x: bounds.size.width, y: bounds.size.height),
                                             CGPoint(x: bounds.origin.x, y: bounds.size.height)]
        
        let fillColor = UIColor(red: 0/255, green: 134/255, blue: 234/255, alpha: 1)
        
        for i in 0..<4 {
            let shape = CAShapeLayer()
            shape.path = getCircleShapePath(inCenter: initialPositions[i], radius: 10).cgPath
            shape.fillColor = fillColor.cgColor
            layer.addSublayer(shape)
            circleShapes.append(shape)
        }

        let centerShapeSize = CGSize(width: 40, height: 10)
        
        for i in 0..<4 {
            let shape = CAShapeLayer()
            let nextIndex = i + 1 == 4 ? 0 : i + 1
            let midPoint = findCeneterBetween(point: initialPositions[i], andPoint: initialPositions[nextIndex])
            shape.path = getCenterShapePath(rect: CGRect(x: midPoint.x,
                                                         y: midPoint.y,
                                                         width: centerShapeSize.width,
                                                         height: centerShapeSize.height)).cgPath
            
            
            shape.anchorPoint = CGPoint(x: 0.5, y: 0.5)
            shape.transform = CATransform3DRotate(shape.transform, degreesToRadians(0.0), 0.0, 0.0, 1.0)
            shape.fillColor = fillColor.cgColor
            layer.addSublayer(shape)
            centerShapes.append(shape)
        }
        
        let path = UIBezierPath()
        path.move(to: initialPositions.first!)

        for i in 1..<initialPositions.count {
            path.addLine(to: initialPositions[i])
        }

        path.close()

        rectangleShape.fillColor = UIColor(red: 0/255, green: 134/255, blue: 234/255, alpha: 0.3).cgColor
        rectangleShape.strokeColor = UIColor(red: 0/255, green: 134/255, blue: 234/255, alpha: 1).cgColor
        rectangleShape.path = path.cgPath
        layer.addSublayer(rectangleShape)
    }
    
    func getCircleShapePath(inCenter point: CGPoint, radius: CGFloat) -> UIBezierPath {
        let path = UIBezierPath(arcCenter: point, radius: radius, startAngle: 0.degreesToRadians, endAngle: 360.degreesToRadians, clockwise: true)
        
        return path
    }
    
    func getCenterShapePath(rect: CGRect) -> UIBezierPath {
        let path =  UIBezierPath(roundedRect: rect, cornerRadius: rect.height/4)
        
        return path
    }
    
    func findCeneterBetween(point a: CGPoint, andPoint b: CGPoint) -> CGPoint {
        let x = (a.x + b.x) / 2
        let y = (a.y + b.y) / 2
        
        return CGPoint(x: x, y: y)
    }
    
    func degreesToRadians(_ degrees: Double) -> CGFloat {
        return CGFloat(degrees * .pi / 180.0)
    }
}
