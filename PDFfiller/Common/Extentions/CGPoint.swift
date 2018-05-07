//
//  CGPoint.swift
//  PDFfiller
//
//  Created by Vladimir Vybornov on 5/3/18.
//  Copyright © 2018 Ilya Kostyukevich. All rights reserved.
//

import UIKit

extension CGPoint {
    
    func horizontalAngle(forPoint point: CGPoint) -> CGFloat {
        return atan2(point.y - self.y, point.x - self.x)
    }
    
    func closestPointOnLineSegment(startPoint p1: CGPoint, endPoint p2: CGPoint) -> CGPoint {
        let v = CGPoint(x: p2.x - p1.x, y: p2.y - p1.y)
        var t: CGFloat = (self.x * v.x - p1.x * v.x + self.y * v.y - p1.y * v.y) / (v.x * v.x + v.y * v.y)
        if t < 0 { t = 0 }
        else if t > 1 { t = 1 }
        
        return CGPoint(x: p1.x + t * v.x, y: p1.y + t * v.y)
    }
}

extension CGPoint: Comparable {
    public static func < (lhs: CGPoint, rhs: CGPoint) -> Bool {
        return lhs.x < rhs.x && lhs.y < rhs.y
    }
    
    public static func == (lhs: CGPoint, rhs: CGPoint) -> Bool {
        return lhs.x == rhs.x && lhs.y == rhs.y
    }
}

extension CGFloat {
    var degreesToRadians: CGFloat { return self * .pi / 180 }
}
