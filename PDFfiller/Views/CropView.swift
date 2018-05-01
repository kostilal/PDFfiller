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
    private let rectangleShapes = CAShapeLayer()
    
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

//        shape.fillColor = UIColor(red: 0/255, green: 134/255, blue: 234/255, alpha: 0.3).cgColor
//        shape.strokeColor = UIColor(red: 0/255, green: 134/255, blue: 234/255, alpha: 1).cgColor
//        shape.lineWidth = CornerDragView.size.width/4
//        
//        layer.addSublayer(shape)
    }
    
    func setupDragLayers() {
        let initialPositions = positions ?? [CGPoint(x: bounds.origin.x, y: bounds.origin.y),
                                             CGPoint(x: bounds.origin.x + bounds.size.width, y: bounds.origin.y),
                                             CGPoint(x: bounds.size.width, y: bounds.size.height),
                                             CGPoint(x: bounds.origin.x, y: bounds.size.height)]
        
        for i in 0..<4 {
            let shape = CAShapeLayer()
            shape.path = getDotPath(inCenter: initialPositions[i], radius: 10).cgPath
            shape.fillColor = UIColor(red: 0/255, green: 134/255, blue: 234/255, alpha: 1).cgColor
            layer.addSublayer(shape)
            circleShapes.append(shape)
        }

        drawShape()
    }
    
    func getDotPath(inCenter point: CGPoint, radius: CGFloat) -> UIBezierPath {
        let path = UIBezierPath(arcCenter: point, radius: radius, startAngle: 0.degreesToRadians, endAngle: 360.degreesToRadians, clockwise: true)
        
        return path
    }
    
    func drawShape() {
//        let path = UIBezierPath()
//        path.move(to: dragableViews.first!.center)
//
//        for i in 1..<dragableViews.count {
//            path.addLine(to: dragableViews[i].center)
//        }
//
//        path.close()

//        shape.path = path.cgPath
    }
}
