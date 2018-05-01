//
//  MainViewController.swift
//  PDFfiller
//
//  Created by Костюкевич Илья on 30.04.2018.
//  Copyright © 2018 Ilya Kostyukevich. All rights reserved.
//

import UIKit

class MainViewController: UIViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    private var imagePicker = UIImagePickerController()
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController?.navigationBar.isHidden = true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        imagePicker.allowsEditing = false
        imagePicker.delegate = self
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Actions
    
    @IBAction func cameraButtonPressed(_ sender: Any) {
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            imagePicker.sourceType = .camera
            presentImagePicker()
        } else {
            let alert  = UIAlertController(title: "Warning", message: "You don't have camera", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            present(alert, animated: true, completion: nil)
        }
    }
    
    @IBAction func galleryButtonPressed(_ sender: Any) {
        imagePicker.sourceType = .photoLibrary
        presentImagePicker()
    }
    
    private func presentImagePicker() {
        present(imagePicker, animated: true, completion: nil)
    }
    
    
    // MARK: - UIImagePickerControllerDelegate
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        imagePicker.dismiss(animated: true) {
            self.performSegue(withIdentifier: "ShowCrop", sender: info[UIImagePickerControllerOriginalImage])
        }
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard var cropVC = segue.destination as? CropViewControllerProtocol , let image = sender as? UIImage else {
            return
        }
        
        cropVC.image = image
        navigationController?.navigationBar.isHidden = false
    }
}
