//
//  PhotoEditingViewController.swift
//  Photo Extension
//
//  Created by Dylan Wang on 2020/1/5.
//  Copyright © 2020 WangXingbin. All rights reserved.
//

import UIKit
import Photos
import PhotosUI

class PhotoEditingViewController: UIViewController, PHContentEditingController {

    @IBOutlet weak var imageView: UIImageView!
    var input: PHContentEditingInput?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
        
    // MARK: - PHContentEditingController
    
    func canHandle(_ adjustmentData: PHAdjustmentData) -> Bool {
        // Inspect the adjustmentData to determine whether your extension can work with past edits.
        // (Typically, you use its formatIdentifier and formatVersion properties to do this.)
        return false
    }
    
    func startContentEditing(with contentEditingInput: PHContentEditingInput, placeholderImage: UIImage) {
        // Present content for editing, and keep the contentEditingInput for use when closing the edit session.
        // If you returned true from canHandleAdjustmentData:, contentEditingInput has the original image and adjustment data.
        // If you returned false, the contentEditingInput has past edits "baked in".
        input = contentEditingInput
        
        let displayImage = input!.displaySizeImage
        let hipsterize = Hipsterize(image: displayImage!)
        imageView.image = hipsterize.processedImage()
    }
    
    func finishContentEditing(completionHandler: @escaping ((PHContentEditingOutput?) -> Void)) {
        // Update UI to reflect that editing has finished and output is being rendered.
        
        // Render and provide output on a background queue.
        DispatchQueue.global().async {
            // Create editing output from the editing input.
            let output = PHContentEditingOutput(contentEditingInput: self.input!)
            
            let fullImage = self.imageView.image
            
            let jpegData = fullImage?.jpegData(compressionQuality: 0.8)
            do {
                try jpegData?.write(to: output.renderedContentURL)
                output.adjustmentData = PHAdjustmentData(formatIdentifier: "com.hipsterize", formatVersion: "1.0", data: try NSKeyedArchiver.archivedData(withRootObject: ["test": "hi"], requiringSecureCoding: true))
            } catch {
                print(error)
            }
            
            // Provide new adjustments and render output to given location.
            // output.adjustmentData = <#new adjustment data#>
            // let renderedJPEGData = <#output JPEG#>
            // renderedJPEGData.writeToURL(output.renderedContentURL, atomically: true)
            
            // Call completion handler to commit edit to Photos.
            completionHandler(output)
            
            // Clean up temporary files, etc.
        }
    }
    
    var shouldShowCancelConfirmation: Bool {
        // Determines whether a confirmation to discard changes should be shown to the user on cancel.
        // (Typically, this should be "true" if there are any unsaved changes.)
        return false
    }
    
    func cancelContentEditing() {
        // Clean up temporary files, etc.
        // May be called after finishContentEditingWithCompletionHandler: while you prepare output.
    }

}
