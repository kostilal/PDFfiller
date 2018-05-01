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
    
    @IBOutlet weak var resetButton: UIButton!
    @IBOutlet weak var cropView: CropView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        cropView.image = image
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
