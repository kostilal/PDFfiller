//
//  EllipseShape.swift
//  PDFfiller
//
//  Created by Костюкевич Илья on 01.05.2018.
//  Copyright © 2018 Ilya Kostyukevich. All rights reserved.
//

import UIKit

enum ShapeAxis {
    case horizontal
    case vertical
}

class EllipseShape: DragableShape {
    
    enum PositionType {
        case top, bottom
        case left, right
    }
    
    var positionType = PositionType.left
    
    var axis: ShapeAxis?
    
    var size: CGSize = CGSize(width: 40, height: 10) {
        didSet {
            redraw()
        }
    }
    
    var angle: CGFloat = 0 {
        didSet {
            redraw()
        }
    }
    
    override func redraw() {
        super.redraw()
        
        let rect = CGRect(x: centerPoint.x - size.width/2, y: centerPoint.y - size.height/2, width: size.width, height: size.height)
        path = getEllipseShapePath(rect: rect).cgPath
    }
    
    private func getEllipseShapePath(rect: CGRect) -> UIBezierPath {
        let path = UIBezierPath(roundedRect: rect, cornerRadius: radius)
        
        var pathTransform  = CGAffineTransform.identity
        pathTransform = pathTransform.translatedBy(x: centerPoint.x, y: centerPoint.y)
        pathTransform = pathTransform.rotated(by: angle)
        pathTransform = pathTransform.translatedBy(x: -centerPoint.x, y: -centerPoint.y)
        path.apply(pathTransform)

        return path
    }
}

extension EllipseShape {
    func positionAlongLine(withStartingPoint first: CGPoint, andSecond second: CGPoint) {
        let lineAngle = first.horizontalAngle(forPoint: second)
        self.angle = lineAngle
    }
}
