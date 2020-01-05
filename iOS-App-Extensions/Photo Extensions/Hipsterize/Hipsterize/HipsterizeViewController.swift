//
//  HipsterizeViewController.swift
//  Hipsterize
//
//  Created by Dylan Wang on 2020/1/5.
//  Copyright © 2020 WangXingbin. All rights reserved.
//

import UIKit

class HipsterizeViewController: UIViewController {
    
    @IBOutlet weak var imageView: UIImageView!
    
    var image: UIImage?
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func selectPhotoTapped(sender: AnyObject) {
        let picker = UIImagePickerController()
        picker.delegate = self
        present(picker, animated: true, completion: nil)
    }
    
    func startEditingImage() {
        if let image = image {
            imageView.image = image
            autoHipsterizeCurrentImage()
        }
    }
    
    func autoHipsterizeCurrentImage() {
        if let image = self.image {
            let hipsterize = Hipsterize(image: image)
            imageView.image = hipsterize.processedImage()
        }
    }
}

extension HipsterizeViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        self.image = info[.originalImage] as? UIImage
        startEditingImage()
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
}

