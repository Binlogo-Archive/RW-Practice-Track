/// Copyright (c) 2020 Razeware LLC
///
/// Permission is hereby granted, free of charge, to any person obtaining a copy
/// of this software and associated documentation files (the "Software"), to deal
/// in the Software without restriction, including without limitation the rights
/// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
/// copies of the Software, and to permit persons to whom the Software is
/// furnished to do so, subject to the following conditions:
///
/// The above copyright notice and this permission notice shall be included in
/// all copies or substantial portions of the Software.
///
/// Notwithstanding the foregoing, you may not use, copy, modify, merge, publish,
/// distribute, sublicense, create a derivative work, and/or sell copies of the
/// Software in any work that is designed, intended, or marketed for pedagogical or
/// instructional purposes related to programming, coding, application development,
/// or information technology.  Permission for such use, copying, modification,
/// merger, publication, distribution, sublicensing, creation of derivative works,
/// or sale is expressly withheld.
///
/// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
/// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
/// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
/// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
/// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
/// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
/// THE SOFTWARE.

import UIKit
import Photos

let StitchEditSegueID = "StitchEditSegue"

class StitchDetailViewController: UIViewController {

  @IBOutlet private var imageView: UIImageView!
  @IBOutlet private var editButton: UIBarButtonItem!
  @IBOutlet private var favoriteButton: UIBarButtonItem!
  @IBOutlet private var deleteButton: UIBarButtonItem!
  
  private var stitchAssets: [PHAsset]?
  var asset: PHAsset!

  // MARK: - UIViewController
  
  override func viewDidLoad() {
    super.viewDidLoad()
    PHPhotoLibrary.shared().register(self)
  }
  
  deinit {
    PHPhotoLibrary.shared().unregisterChangeObserver(self)
  }
  
  override func viewWillAppear(_ animated: Bool)  {
    super.viewWillAppear(animated)
    displayImage()
    editButton.isEnabled = asset.canPerform(.content)
    favoriteButton.isEnabled = asset.canPerform(.properties)
    deleteButton.isEnabled = asset.canPerform(.delete)
    updateFavoriteButton()
  }
  
  // MARK: - Private
  
  private func displayImage() {
    let scale = UIScreen.main.scale
    let targetSize = CGSize(width: imageView.bounds.width * scale, height: imageView.bounds.height * scale)
    
    let options = PHImageRequestOptions()
    options.deliveryMode = .highQualityFormat
    options.isNetworkAccessAllowed = true
    
    PHImageManager.default().requestImage(for: asset, targetSize: targetSize, contentMode: .aspectFill, options: options) { (result, info) in
      if result != nil {
        self.imageView.image = result
      }
    }
  }
  
  private func updateFavoriteButton() {
    if asset.isFavorite {
      favoriteButton.title = "Unfavorite"
    } else {
      favoriteButton.title = "Favorite"
    }
  }
  
  // MARK: - Segue
  
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    if segue.identifier == StitchEditSegueID,
      let nav = segue.destination as? UINavigationController,
      let dest = nav.viewControllers[0] as? AssetCollectionsViewController {
      dest.delegate = self
      dest.selectedAssets = stitchAssets ?? []
    }
  }
  
  // MARK: - Actions
  
  @IBAction func favoriteTapped(_ sender:AnyObject) {
    PHPhotoLibrary.shared().performChanges({
      let request = PHAssetChangeRequest(for: self.asset)
      request.isFavorite = !self.asset.isFavorite
    })
  }
  
  @IBAction func deleteTapped(_ sender:AnyObject) {
    PHPhotoLibrary.shared().performChanges({
      if let asset = self.asset {
        PHAssetChangeRequest.deleteAssets([asset] as NSArray)
      }
    })
  }
  
  @IBAction func editTapped(_ sender:AnyObject) {
    StitchHelper.loadAssetsInStitch(stitch: asset) { (stitchAssets) in
      self.stitchAssets = stitchAssets
      self.performSegue(withIdentifier: StitchEditSegueID, sender: self)
    }
  }
}

// MARK: - AssetPickerDelegate

extension StitchDetailViewController: AssetPickerDelegate {

  func assetPickerDidCancel() {
    dismiss(animated: true, completion: nil)
  }
  
  func assetPickerDidFinishPickingAssets(selectedAssets: [PHAsset])  {
    dismiss(animated: true, completion: nil)
    if let stitchImage = StitchHelper.createStitchImageWithAssets(selectedAssets) {
      StitchHelper.editStitchContentWith(asset, image: stitchImage, assets: selectedAssets)
    }
  }
}

// MARK: - PHPhotoLibraryChangeObserver

extension StitchDetailViewController: PHPhotoLibraryChangeObserver {
  func photoLibraryDidChange(_ changeInstance: PHChange)  {
    DispatchQueue.main.async {
      if let changeDetails = changeInstance.changeDetails(for: self.asset) {
        if changeDetails.objectWasDeleted {
          self.navigationController?.popViewController(animated: true)
          return
        }
        self.asset = changeDetails.objectAfterChanges
        if changeDetails.assetContentChanged {
          self.displayImage()
        }
        self.updateFavoriteButton()
      }
    }
  }
}
