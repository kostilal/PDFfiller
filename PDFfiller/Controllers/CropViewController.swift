//
//  CropViewController.swift
//  PDFfiller
//
//  Created by Костюкевич Илья on 30.04.2018.
//  Copyright © 2018 Ilya Kostyukevich. All rights reserved.
//

import UIKit

protocol CropViewControllerProtocol {
    var image: UIImage? { get set }
}

class CropViewController: UIViewController, CropViewControllerProtocol {
    var image: UIImage?
    var cropView: CropView?
    
    @IBOutlet weak var resetButton: UIButton!
    @IBOutlet weak var imageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        imageView.image = image
        setupCropView()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        cropView?.redrawShapes(imageView.frame)
    }
    
    func setupCropView() {
        cropView = CropView(frame: view.frame, cropedObjectFrame: imageView.frame, shapePositions: nil)
        view.addSubview(cropView!)
    }
    
    // MARK: - Actions
    
    @IBAction func resetButtonPressed(_ sender: Any) {
         cropView?.redrawShapes(imageView.frame)
    }
    
    @IBAction func cancelButtonPressed(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func applyButtonPressed(_ sender: Any) {
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
