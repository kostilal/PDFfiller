//
//  EllipseShape.swift
//  PDFfiller
//
//  Created by Костюкевич Илья on 01.05.2018.
//  Copyright © 2018 Ilya Kostyukevich. All rights reserved.
//

import UIKit

class EllipseShape: CAShapeLayer {
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
    
    var size: CGSize {
        didSet {
            redraw()
        }
    }
    
    var angle: Int {
        didSet {
            redraw()
        }
    }
    
    init(centerPoint: CGPoint = CGPoint.zero,
         angle: Int = 0,
         radius: CGFloat = 10,
         color: UIColor = UIColor(red: 0/255, green: 134/255, blue: 234/255, alpha: 1),
         size: CGSize = CGSize(width: 40, height: 10)) {
        
        self.centerPoint = centerPoint
        self.radius = radius
        self.color = color
        self.size = size
        self.angle = angle
        
        super.init()
        
        redraw()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func redraw() {
        fillColor = color.cgColor
        path = getEllipseShapePath(rect: CGRect(x: centerPoint.x - size.width/2,
                                                y: centerPoint.y - size.height/2,
                                                width: size.width,
                                                height: size.height)).cgPath
        
        setAffineTransform(CGAffineTransform(rotationAngle: CGFloat(angle.degreesToRadians)))
    }
    
    private func getEllipseShapePath(rect: CGRect) -> UIBezierPath {
        let path =  UIBezierPath(roundedRect: rect, cornerRadius: radius)
        
        return path
    }
}
