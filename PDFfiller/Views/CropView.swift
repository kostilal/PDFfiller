//
//  CropView.swift
//  PDFfiller
//
//  Created by Костюкевич Илья on 30.04.2018.
//  Copyright © 2018 Ilya Kostyukevich. All rights reserved.
//

import UIKit
import QuartzCore

class CropView: UIView {
    private let imageView = UIImageView()
    var image: UIImage? {
        didSet {
            imageView.image = image
        }
    }
    
    var dragableViews = [DragView]()
    var path: UIBezierPath!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        defaultSetup()
        setupDragViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        defaultSetup()
        setupDragViews()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
         imageView.frame = CGRect(x: 0, y: 0, width: bounds.size.width, height: bounds.size.height)
    }
    
    private func defaultSetup() {
        backgroundColor = .white
        addSubview(imageView)
    }
    
    func setupDragViews() {
        let topLeft = CornerDragView(with: self, position: CGPoint(x: bounds.origin.x - CornerDragView.size.width/2,
                                                                   y: bounds.origin.y - CornerDragView.size.height/2))
        dragableViews.append(topLeft)
        
        let topRight = CornerDragView(with: self, position: CGPoint(x: bounds.origin.x + bounds.size.width - CornerDragView.size.width/2,
                                                                    y: bounds.origin.y - CornerDragView.size.height/2))
        dragableViews.append(topRight)
        
        let bottomLeft = CornerDragView(with: self, position: CGPoint(x: bounds.origin.x - CornerDragView.size.width/2,
                                                                      y: bounds.size.height - frame.origin.y - CornerDragView.size.height/2))
        dragableViews.append(bottomLeft)
        
        let bottomRight = CornerDragView(with: self, position: CGPoint(x: bounds.origin.x + bounds.size.width - CornerDragView.size.width/2,
                                                                       y: bounds.size.height - frame.origin.y - CornerDragView.size.height/2))
        
        dragableViews.append(bottomRight)
        
        dragableViews.forEach { (view) in
            addSubview(view)
        }
        
        drawShape()
    }
    
    func drawShape() {
        path = UIBezierPath()
        path.move(to: dragableViews.first!.frame.origin)
       
        for i in 1..<dragableViews.count {
            path.addLine(to: dragableViews[i].frame.origin)
        }
        
        path.close()

        
    }

    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

}
