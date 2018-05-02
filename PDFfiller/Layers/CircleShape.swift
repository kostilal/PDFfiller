//
//  CircleShape.swift
//  PDFfiller
//
//  Created by Костюкевич Илья on 01.05.2018.
//  Copyright © 2018 Ilya Kostyukevich. All rights reserved.
//

import UIKit

class CircleShape: CAShapeLayer {
    var centerPoint: CGPoint = CGPoint.zero {
        didSet {
            redraw()
        }
    }
    
    var radius: CGFloat = 10 {
        didSet {
            redraw()
        }
    }
    
    var color: UIColor = UIColor(red: 0/255, green: 134/255, blue: 234/255, alpha: 1) {
        didSet {
            redraw()
        }
    }

    override init() {
        super.init()
        
        redraw()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        redraw()
    }
    
    override init(layer: Any) {
        super.init(layer: layer)
        
        redraw()
    }
    
    func redraw() {
        fillColor = color.cgColor
        path = getCircleShapePath(inCenter: centerPoint, radius: radius).cgPath
    }
    
    private func getCircleShapePath(inCenter point: CGPoint, radius: CGFloat) -> UIBezierPath {
        let path = UIBezierPath(arcCenter: point, radius: radius, startAngle: 0.degreesToRadians, endAngle: 360.degreesToRadians, clockwise: true)
        
        return path
    }
}
