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
}

extension CGPoint: Comparable {
    public static func < (lhs: CGPoint, rhs: CGPoint) -> Bool {
        return lhs.x > rhs.x && lhs.y > rhs.y
    }
    
    public static func == (lhs: CGPoint, rhs: CGPoint) -> Bool {
        return lhs.x == rhs.x && lhs.y == rhs.y
    }
}


extension CGFloat {
    var degreesToRadians: CGFloat { return self * .pi / 180 }
}
