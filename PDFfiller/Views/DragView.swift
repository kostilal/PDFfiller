//
//  DragView.swift
//  PDFfiller
//
//  Created by Костюкевич Илья on 30.04.2018.
//  Copyright © 2018 Ilya Kostyukevich. All rights reserved.
//

import UIKit
import CoreGraphics

protocol DragViewDelegate {
    func draggingDidBegan(_ view: DragView)
    func draggingDidChanged(_ view: DragView)
    func draggingDidEnd(_ view: DragView)
}

class DragView: UIView {
    private var panGesture: UIPanGestureRecognizer  {
        return UIPanGestureRecognizer(target: self, action: #selector(self.touchHandler(_:)))
    }
    
    open var delegate: DragViewDelegate?
    open var respectedView: UIView?
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        setupTapGesture()
    }
    
    func setupTapGesture() {
        addGestureRecognizer(panGesture)
    }
    
    @objc func touchHandler(_ sender: UIPanGestureRecognizer) {
        let translation = sender.translation(in: respectedView)
        
//        guard let respectedView = self.respectedView, respectedView.bounds.contains(translation) else { return }
        center = CGPoint(x: center.x + translation.x, y: center.y + translation.y)
        sender.setTranslation(CGPoint.zero, in: respectedView)
        
        switch sender.state {
        case .began:
            delegate?.draggingDidBegan(self)
        case .changed:
            delegate?.draggingDidChanged(self)
        case .ended:
            delegate?.draggingDidEnd(self)
        default:
            break
        }
    }
}
