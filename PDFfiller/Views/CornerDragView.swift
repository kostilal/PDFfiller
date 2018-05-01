//
//  CornerDragView.swift
//  PDFfiller
//
//  Created by Костюкевич Илья on 30.04.2018.
//  Copyright © 2018 Ilya Kostyukevich. All rights reserved.
//

import UIKit

class CornerDragView: DragView {
    static let size = CGSize(width: 20, height: 20)
    
    convenience init(with respectedView: UIView, position: CGPoint) {
        self.init(frame: CGRect(x: position.x,
                                y: position.y,
                                width: CornerDragView.size.width,
                                height: CornerDragView.size.height))
        self.respectedView = respectedView
        
        setupUI()
    }
    
    func setupUI() {
        layer.cornerRadius = CornerDragView.size.height / 2
        layer.masksToBounds = true
        backgroundColor = .blue
    }
}
