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

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        cropView?.frame = CGRect(x: 0, y: 0, width: imageView.bounds.width, height: imageView.bounds.height)
    }
    
    func setupCropView() {
        cropView = CropView()
        imageView.addSubview(cropView!)
    }
    
    // MARK: - Actions
    
    @IBAction func resetButtonPressed(_ sender: Any) {
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
