//
//  DragView.swift
//  PDFfiller
//
//  Created by Костюкевич Илья on 30.04.2018.
//  Copyright © 2018 Ilya Kostyukevich. All rights reserved.
//

import UIKit

protocol DragViewDelegate {
    func draggingDidBegan(_ view: DragView)
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
        sender.translation(in: self)
        
        let state = sender.state
        
        guard state == .ended else {
            if state == .began {
                delegate?.draggingDidBegan(self)
            }
            return
        }
        
        delegate?.draggingDidEnd(self)
    }

}
