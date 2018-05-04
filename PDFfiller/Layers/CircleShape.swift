//
//  CircleShape.swift
//  PDFfiller
//
//  Created by Костюкевич Илья on 01.05.2018.
//  Copyright © 2018 Ilya Kostyukevich. All rights reserved.
//

import UIKit

class CircleShape: DragableShape {
    
    enum PositionType {
        case topLeft, topRight
        case bottomLeft, bottomRight
    }
    
    var positionType = PositionType.topLeft
    
    override func redraw() {
        super.redraw()
        
        path = getCircleShapePath(inCenter: centerPoint, radius: radius).cgPath
    }
    
    private func getCircleShapePath(inCenter point: CGPoint, radius: CGFloat) -> UIBezierPath {
        let path = UIBezierPath(arcCenter: point,
                                radius: radius,
                                startAngle: 0.degreesToRadians,
                                endAngle: 360.degreesToRadians,
                                clockwise: true)
        
        return path
    }
}
