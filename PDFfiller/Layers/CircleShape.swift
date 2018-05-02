//
//  CircleShape.swift
//  PDFfiller
//
//  Created by Костюкевич Илья on 01.05.2018.
//  Copyright © 2018 Ilya Kostyukevich. All rights reserved.
//

import UIKit

class CircleShape: CAShapeLayer {
    var centerPoint: CGPoint {
        didSet {
            redraw()
        }
    }
    
    var radius: CGFloat {
        didSet {
            redraw()
        }
    }
    
    var color: UIColor {
        didSet {
            redraw()
        }
    }
    
    init(centerPoint: CGPoint = CGPoint.zero,
         radius: CGFloat = 10,
         color: UIColor = UIColor(red: 0/255, green: 134/255, blue: 234/255, alpha: 1)) {
        
        self.centerPoint = centerPoint
        self.radius = radius
        self.color = color
        
        super.init()
        
        redraw()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
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
