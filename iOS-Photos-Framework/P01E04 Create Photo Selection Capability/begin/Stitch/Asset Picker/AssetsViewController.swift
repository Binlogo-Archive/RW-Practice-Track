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

class AssetsViewController: UICollectionViewController {
 
  let AssetCollectionViewCellReuseIdentifier = "AssetCell"
  
  var assetsFetchResults: PHFetchResult<PHAsset>?
  var selectedAssets: [PHAsset] = []
  
  private let numOffscreenAssetsToCache = 60
  
  private var cellSize: CGSize {
    get {
      return (collectionViewLayout as? UICollectionViewFlowLayout)?.itemSize ?? .zero
    }
  }
  
  let requestOptions: PHImageRequestOptions = {
    let o = PHImageRequestOptions()
    o.isNetworkAccessAllowed = true
    o.resizeMode = .fast
    return o
  }()

  // MARK: - UIViewController
  
  override func viewDidLoad() {
    super.viewDidLoad()
    collectionView.allowsMultipleSelection = true
  }
  
  override func viewWillAppear(_ animated: Bool)  {
    super.viewWillAppear(animated)
    collectionView.reloadData()
    updateSelectedItems()
  }

  func currentAssetAtIndex(_ index:NSInteger) -> PHAsset {
    if let fetchResult = assetsFetchResults {
      return fetchResult[index]
    } else {
      return selectedAssets[index]
    }
  }
  
  func updateSelectedItems() {

  }
}

// MARK: - UICollectionViewDelegate

extension AssetsViewController {
  
  override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {

  }
  
  override func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {

  }
}

// MARK: - UICollectionViewDataSource

extension AssetsViewController {
  
  override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int  {
    if let fetchResult = assetsFetchResults {
      return fetchResult.count
    } else {
      return selectedAssets.count
    }
  }
  
  override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: AssetCollectionViewCellReuseIdentifier, for: indexPath) as! AssetCell
    cell.reuseCount = cell.reuseCount + 1
    let reuseCount = cell.reuseCount
    let asset = currentAssetAtIndex(indexPath.item)
    
    PHImageManager.default().requestImage(for: asset, targetSize: cellSize, contentMode: .aspectFill, options: requestOptions) { (image, metadata) in
      if reuseCount == cell.reuseCount {
        cell.imageView.image = image
      }
    }
    return cell
  }
}

// MARK: - UICollectionViewDelegateFlowLayout

extension AssetsViewController: UICollectionViewDelegateFlowLayout {
  
  private func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
    var thumbsPerRow: Int
    switch collectionView.bounds.size.width {
    case 0..<400:
      thumbsPerRow = 3
    case 400..<600:
      thumbsPerRow = 4
    case 600..<800:
      thumbsPerRow = 5
    case 800..<1200:
      thumbsPerRow = 6
    default:
      thumbsPerRow = 4
    }
    let width = collectionView.bounds.size.width / CGFloat(thumbsPerRow)
    return CGSize(width: width, height: width)
  }
}

// MARK: - Caching

extension AssetsViewController {
  
}

// MARK: - UIScrollViewDelegate

extension AssetsViewController {
  override func scrollViewDidScroll(_ scrollView: UIScrollView) {

  }
}

// MARK: - PHPhotoLibraryChangeObserver

extension AssetsViewController: PHPhotoLibraryChangeObserver {
  func photoLibraryDidChange(_ changeInstance: PHChange)  {

  }
}
