//
//  EllipseShape.swift
//  PDFfiller
//
//  Created by Костюкевич Илья on 01.05.2018.
//  Copyright © 2018 Ilya Kostyukevich. All rights reserved.
//

import UIKit

class EllipseShape: DragableShape {
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
    
    override func redraw() {
        super.redraw()
        
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
