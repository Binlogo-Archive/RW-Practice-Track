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
import CoreGraphics

let StitchWidth = 900
let MaxPhotosPerStitch = 6

let StitchAdjustmentFormatIdentifier = "RW.stitch.adjustmentFormatID"

class StitchHelper: NSObject {
  
  // MARK: - Stitch Creation
  
  class func createNewStitchWith(assets: [PHAsset], inCollection collection: PHAssetCollection) {
    guard let stitchImage = createStitchImageWithAssets(assets) else {
      return
    }
    PHPhotoLibrary.shared().performChanges({
      let assetChangeRequest = PHAssetChangeRequest.creationRequestForAsset(from: stitchImage)
      guard let stitchPlaceholder = assetChangeRequest.placeholderForCreatedAsset else {
        return
      }
      let contentEditingOutput = PHContentEditingOutput(placeholderForCreatedAsset: stitchPlaceholder)
      contentEditingOutput.adjustmentData = createAdjustmentData(assets)
      writeImage(stitchImage, to: contentEditingOutput.renderedContentURL)
      assetChangeRequest.contentEditingOutput = contentEditingOutput
      
      let assetCollectionChangeRequest = PHAssetCollectionChangeRequest(for: collection)
      assetCollectionChangeRequest?.addAssets([stitchPlaceholder] as NSArray)
    })
  }
  
  // MARK: - Stitch Content
  
  class func editStitchContentWith(_ stitch: PHAsset, image: UIImage, assets: [PHAsset]) {
    stitch.requestContentEditingInput(with: nil) { (contentEditingInput, _) in
      guard let contentEditingInput = contentEditingInput,
        let adjustmentData = createAdjustmentData(assets) else {
          return
      }
      let contentEditingOutput = PHContentEditingOutput(contentEditingInput: contentEditingInput)
      contentEditingOutput.adjustmentData = adjustmentData
      writeImage(image, to: contentEditingOutput.renderedContentURL)
      PHPhotoLibrary.shared().performChanges({
        let request = PHAssetChangeRequest(for: stitch)
        request.contentEditingOutput = contentEditingOutput
      })
    }
  }
  
  class func loadAssetsInStitch(stitch: PHAsset, completion: @escaping ([PHAsset]) -> ()) {
    let options = PHContentEditingInputRequestOptions()
    options.canHandleAdjustmentData = { adjustmentData in
      return adjustmentData.formatIdentifier == StitchAdjustmentFormatIdentifier && adjustmentData.formatVersion == "1.0"
    }
    stitch.requestContentEditingInput(with: options) { (contentEditingInput, info) in
      do {
        if let adjustmentData = contentEditingInput?.adjustmentData,
          let stitchAssetIDs = try NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(adjustmentData.data) as? [String] {
          let stitchAssetsFetchResult = PHAsset.fetchAssets(withLocalIdentifiers: stitchAssetIDs, options: nil)
          var stitchAssets: [PHAsset] = []
          stitchAssetsFetchResult.enumerateObjects { (object, _, _) in
            stitchAssets.append(object)
          }
          completion(stitchAssets)
        }
      } catch {}
    }
  }
  
  // MARK: - Stitch Image Creation
  
  class func createStitchImageWithAssets(_ assets: [PHAsset]) -> UIImage? {
    var assetCount = assets.count
    // Cap to 6 max photos
    if (assetCount > MaxPhotosPerStitch) {
      assetCount = MaxPhotosPerStitch
    }
    // Calculate placement rects
    let placementRects = placementRectsForAssetCount(assetCount)
    // Create context to draw images
    let deviceScale = UIScreen.main.scale
    UIGraphicsBeginImageContextWithOptions(CGSize(width: StitchWidth, height: StitchWidth), true, deviceScale)
    
    let options = PHImageRequestOptions()
    options.isSynchronous = true
    options.resizeMode = .exact
    options.deliveryMode = .highQualityFormat
    
    // Draw each image into their rect
    for i in 0..<assets.count {
      let rect = placementRects[i]
      let asset = assets[i]
      let targetSize = CGSize(width: rect.width*deviceScale, height: rect.height*deviceScale)
      PHImageManager.default().requestImage(for: asset, targetSize:targetSize, contentMode:.aspectFill, options:options) { result, _ in
        guard let result = result else {
          return
        }
        if result.size != targetSize {
          let croppedResult = self.cropImageToCenterSquare(result, size:targetSize)
          croppedResult?.draw(in: rect)
        } else {
          result.draw(in: rect)
        }
      }
    }
    
    // Grab results
    let result = UIGraphicsGetImageFromCurrentImageContext()
    UIGraphicsEndImageContext()
    
    return result
  }
  
  private class func placementRectsForAssetCount(_ count: Int) -> [CGRect] {
    var rects: [CGRect] = []
    
    var evenCount: Int
    var oddCount: Int
    if count % 2 == 0 {
      evenCount = count
      oddCount = 0
    } else {
      oddCount = 1
      evenCount = count - oddCount
    }
    
    let rectHeight = StitchWidth / (evenCount / 2 + oddCount)
    let evenWidth = StitchWidth / 2
    let oddWidth = StitchWidth
    
    for i in 0..<evenCount {
      let rect = CGRect(x: i%2 * evenWidth, y: i/2 * rectHeight, width: evenWidth, height: rectHeight)
      rects.append(rect)
    }
    
    if oddCount > 0 {
      let rect = CGRect(x: 0, y: evenCount/2 * rectHeight, width: oddWidth, height: rectHeight)
      rects.append(rect)
    }
    
    return rects
  }
  
  // Helper to crop Image if it wasn't properly cropped
  private class func cropImageToCenterSquare(_ image: UIImage, size: CGSize) -> UIImage? {
    let ratio = min(image.size.width / size.width, image.size.height / size.height)
    
    let newSize = CGSize(width: image.size.width / ratio, height: image.size.height / ratio)
    let offset = CGPoint(x: 0.5 * (size.width - newSize.width), y: 0.5 * (size.height - newSize.height))
    let rect = CGRect(origin: offset, size: newSize)
    
    UIGraphicsBeginImageContext(size)
    image.draw(in: rect)
    let output = UIGraphicsGetImageFromCurrentImageContext()
    UIGraphicsEndImageContext()
    
    return output
  }
  
  class func createAdjustmentData(_ assets: [PHAsset]) -> PHAdjustmentData? {
    do {
      let assetIDs = assets.map { asset in
        (asset as PHAsset).localIdentifier
      }
      let assetsData =
        try NSKeyedArchiver.archivedData(withRootObject: assetIDs, requiringSecureCoding: false)
      let adjustmentData = PHAdjustmentData(formatIdentifier: StitchAdjustmentFormatIdentifier,
                              formatVersion: "1.0",
                              data: assetsData)
      return adjustmentData
    } catch {}
    return nil
  }
  
  class func writeImage(_ image: UIImage, to url: URL) {
    do {
      let stitchJPEG = image.jpegData(compressionQuality: 0.9)
      try stitchJPEG?.write(to: url, options: .atomic)
    } catch {}
  }
}
