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

protocol SelectedAssetsDelegate {
  func updateSelectedAssets(_ assets: [PHAsset])
}

class AssetsViewController: UICollectionViewController {
 
  var delegate: SelectedAssetsDelegate?
  let AssetCollectionViewCellReuseIdentifier = "AssetCell"
  
  var assetsFetchResults: PHFetchResult<PHAsset>?
  var selectedAssets: [PHAsset] = []
  
  private let numOffscreenAssetsToCache = 60
  private let imageManager: PHCachingImageManager = PHCachingImageManager()
  private var cachedIndexes: [IndexPath] = []
  private var lastCacheFrameCenter: CGFloat = 0
  private var cacheQueue = DispatchQueue(label: "cache_queue")
  
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
    PHPhotoLibrary.shared().register(self)
    collectionView.allowsMultipleSelection = true
  }
  
  deinit {
    PHPhotoLibrary.shared().unregisterChangeObserver(self)
  }
  
  override func viewWillAppear(_ animated: Bool)  {
    super.viewWillAppear(animated)
    resetCache()
    collectionView.reloadData()
    updateSelectedItems()
  }
  
  override func viewWillDisappear(_ animated: Bool) {
    delegate?.updateSelectedAssets(selectedAssets)
  }

  func currentAssetAtIndex(_ index:NSInteger) -> PHAsset {
    if let fetchResult = assetsFetchResults {
      return fetchResult[index]
    } else {
      return selectedAssets[index]
    }
  }
  
  func updateSelectedItems() {
    if let fetchResult = assetsFetchResults {
      for asset in selectedAssets {
        let index = fetchResult.index(of: asset)
        if index != NSNotFound {
          let indexPath = IndexPath(item: index, section: 0)
          collectionView.selectItem(at: indexPath, animated: false, scrollPosition: [])
        }
      }
    } else {
      for i in 0..<selectedAssets.count {
        let indexPath = IndexPath(item: i, section: 0)
        collectionView.selectItem(at: indexPath, animated: false, scrollPosition: [])
      }
    }
  }
}

// MARK: - UICollectionViewDelegate

extension AssetsViewController {
  
  override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    let asset = currentAssetAtIndex(indexPath.item)
    selectedAssets.append(asset)
  }
  
  override func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
    let assetToDelete = currentAssetAtIndex(indexPath.item)
    selectedAssets = selectedAssets.filter({ (asset) -> Bool in
      return asset != assetToDelete
    })
    if assetsFetchResults == nil {
      collectionView.deleteItems(at: [indexPath])
    }
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
    
    imageManager.requestImage(for: asset, targetSize: cellSize, contentMode: .aspectFill, options: requestOptions) { (image, metadata) in
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
  
  func updateCache() {
    let currentFrameCenter = collectionView.bounds.minY
    let height = collectionView.bounds.height
    let visibleIndexes = collectionView.indexPathsForVisibleItems.sorted { (a, b) -> Bool in
      return a.item < b.item
    }
    guard abs(currentFrameCenter - lastCacheFrameCenter) >= height/3.0,
      visibleIndexes.count > 0 else {
        return
    }
    lastCacheFrameCenter = currentFrameCenter
    
    let totalItemCount = assetsFetchResults?.count ?? selectedAssets.count
    let firstItemToCache = max(visibleIndexes[0].item - numOffscreenAssetsToCache / 2, 0)
    let lastItemToCache = min(visibleIndexes[visibleIndexes.count - 1].item + numOffscreenAssetsToCache / 2, totalItemCount - 1)
    
    var indexesToStartCaching: [IndexPath] = []
    for i in firstItemToCache..<lastItemToCache {
      let indexPath = IndexPath(item: i, section: 0)
      if !cachedIndexes.contains(indexPath) {
        indexesToStartCaching.append(indexPath)
      }
    }
    cachedIndexes += indexesToStartCaching
    imageManager.startCachingImages(for: assetsAtIndexPaths(indexesToStartCaching), targetSize: cellSize, contentMode: .aspectFill, options: requestOptions)
    
    var indexesToStopCaching: [IndexPath] = []
    cachedIndexes = cachedIndexes.filter({ (indexPath) -> Bool in
      if indexPath.item < firstItemToCache || indexPath.item > lastItemToCache {
        indexesToStopCaching.append(indexPath)
        return false
      }
      return true
    })
    imageManager.stopCachingImages(for: assetsAtIndexPaths(indexesToStopCaching), targetSize: cellSize, contentMode: .aspectFill, options: requestOptions)
  }
  
  func assetsAtIndexPaths(_ indexPaths: [IndexPath]) -> [PHAsset] {
    return indexPaths.map { (indexPath) -> PHAsset in
      return self.currentAssetAtIndex(indexPath.item)
    }
  }
  
  func resetCache() {
    imageManager.stopCachingImagesForAllAssets()
    cachedIndexes = []
    lastCacheFrameCenter = 0
  }
}

// MARK: - UIScrollViewDelegate

extension AssetsViewController {
  override func scrollViewDidScroll(_ scrollView: UIScrollView) {
    cacheQueue.sync {
      self.updateCache()
    }
  }
}

// MARK: - PHPhotoLibraryChangeObserver

extension AssetsViewController: PHPhotoLibraryChangeObserver {
  func photoLibraryDidChange(_ changeInstance: PHChange)  {
    DispatchQueue.main.async {
      if let assetsFetchResults = self.assetsFetchResults,
        let collectionChanges = changeInstance.changeDetails(for: assetsFetchResults) {
        self.assetsFetchResults = collectionChanges.fetchResultAfterChanges
        if collectionChanges.hasMoves || !collectionChanges.hasIncrementalChanges {
          self.collectionView.reloadData()
        } else {
          self.collectionView.performBatchUpdates({
            if let removedIndexes = collectionChanges.removedIndexes, removedIndexes.count > 0 {
              self.collectionView.deleteItems(at: removedIndexes.indexPaths(for: 0))
            }
            if let insertedIndexes = collectionChanges.insertedIndexes, insertedIndexes.count > 0 {
              self.collectionView.insertItems(at: insertedIndexes.indexPaths(for: 0))
            }
            if let changedIndexes = collectionChanges.changedIndexes, changedIndexes.count > 0 {
              self.collectionView.reloadItems(at: changedIndexes.indexPaths(for: 0))
            }
          })
        }
      }
    }
  }
}
