//
//  CropView.swift
//  PDFfiller
//
//  Created by Костюкевич Илья on 30.04.2018.
//  Copyright © 2018 Ilya Kostyukevich. All rights reserved.
//

import UIKit
import QuartzCore

class CropView: UIView, DragViewDelegate {
    
    private let imageView = UIImageView()
    private var dragableViews = [DragView]()
    private let shape = CAShapeLayer()
    
    var image: UIImage? {
        didSet {
            imageView.image = image
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        defaultSetup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        defaultSetup()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
         imageView.frame = CGRect(x: 0, y: 0, width: bounds.size.width, height: bounds.size.height)
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        setupDragViews()
    }
    
    private func defaultSetup() {
        backgroundColor = .white
        addSubview(imageView)
        
        shape.fillColor = UIColor(red: 0/255, green: 134/255, blue: 234/255, alpha: 0.3).cgColor
        shape.strokeColor = UIColor(red: 0/255, green: 134/255, blue: 234/255, alpha: 1).cgColor
        shape.lineWidth = CornerDragView.size.width/4
        
        layer.addSublayer(shape)
    }
    
    func setupDragViews() {
        let topLeft = CornerDragView(with: self, position: CGPoint(x: bounds.origin.x,
                                                                   y: bounds.origin.y))
        dragableViews.append(topLeft)
        
        let topRight = CornerDragView(with: self, position: CGPoint(x: bounds.origin.x + bounds.size.width - CornerDragView.size.width,
                                                                    y: bounds.origin.y - CornerDragView.size.height))
        dragableViews.append(topRight)
        
        let bottomRight = CornerDragView(with: self, position: CGPoint(x: bounds.size.width - CornerDragView.size.width,
                                                                       y: bounds.size.height - CornerDragView.size.height))
        
        dragableViews.append(bottomRight)
        
        let bottomLeft = CornerDragView(with: self, position: CGPoint(x: bounds.origin.x - CornerDragView.size.width,
                                                                      y: bounds.size.height - CornerDragView.size.height))
        dragableViews.append(bottomLeft)
        
        dragableViews.forEach { (view) in
            addSubview(view)
            view.delegate = self
        }
        
        drawShape()
    }
    
    func draggingDidBegan(_ view: DragView) {
        
    }
    
    func draggingDidEnd(_ view: DragView) {
        
    }
    
    func draggingDidChanged(_ view: DragView) {
        drawShape()
    }
    
    func drawShape() {
        let path = UIBezierPath()
        path.move(to: dragableViews.first!.center)

        for i in 1..<dragableViews.count {
            path.addLine(to: dragableViews[i].center)
        }

        path.close()

        shape.path = path.cgPath
    }

    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

}
