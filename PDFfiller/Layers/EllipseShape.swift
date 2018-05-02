//
//  EllipseShape.swift
//  PDFfiller
//
//  Created by Костюкевич Илья on 01.05.2018.
//  Copyright © 2018 Ilya Kostyukevich. All rights reserved.
//

import UIKit

class EllipseShape: CAShapeLayer {
    var centerPoint: CGPoint = CGPoint.zero {
        didSet {
            redraw()
        }
    }
    
    var radius: CGFloat  = 10 {
        didSet {
            redraw()
        }
    }
    
    var color: UIColor = UIColor(red: 0/255, green: 134/255, blue: 234/255, alpha: 1) {
        didSet {
            redraw()
        }
    }
    
    var size: CGSize = CGSize(width: 40, height: 10) {
        didSet {
            redraw()
        }
    }
    
    var angle: Int = 0 {
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
        path = getEllipseShapePath(rect: CGRect(x: centerPoint.x - size.width/2,
                                                y: centerPoint.y - size.height/2,
                                                width: size.width,
                                                height: size.height)).cgPath
        
//        setAffineTransform(CGAffineTransform(rotationAngle: CGFloat(angle.degreesToRadians)))
    }
    
    private func getEllipseShapePath(rect: CGRect) -> UIBezierPath {
        let path =  UIBezierPath(roundedRect: rect, cornerRadius: radius)
        
        return path
    }
}
