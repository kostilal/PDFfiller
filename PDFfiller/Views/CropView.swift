//
//  CropView.swift
//  PDFfiller
//
//  Created by Костюкевич Илья on 30.04.2018.
//  Copyright © 2018 Ilya Kostyukevich. All rights reserved.
//

import UIKit
import QuartzCore

protocol CropViewProtocol {
    var image: UIImage? { get set }
    var positions: [CGPoint]? { get set }
}

class CropView: UIView, CropViewProtocol {
    private let imageView = UIImageView()
    private var dragableViews = [DragView]()
    private let shape = CAShapeLayer()
    
    var image: UIImage? {
        didSet {
            imageView.image = image
        }
    }
    
    var positions: [CGPoint]?
    
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
         imageView.frame = CGRect(x: CornerDragView.size.width/2,
                                  y: CornerDragView.size.width/2,
                                  width: bounds.size.width - CornerDragView.size.width,
                                  height: bounds.size.height - CornerDragView.size.width)
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        setupDragViews()
    }
    
    private func defaultSetup() {
        backgroundColor = .clear
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
                                                                    y: bounds.origin.y))
        dragableViews.append(topRight)
        
        let bottomRight = CornerDragView(with: self, position: CGPoint(x: bounds.size.width - CornerDragView.size.width,
                                                                       y: bounds.size.height - CornerDragView.size.height))
        
        dragableViews.append(bottomRight)
        
        let bottomLeft = CornerDragView(with: self, position: CGPoint(x: bounds.origin.x,
                                                                      y: bounds.size.height - CornerDragView.size.height))
        dragableViews.append(bottomLeft)
        
        dragableViews.forEach { (view) in
            addSubview(view)
        }
        
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
}
