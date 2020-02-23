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

let StitchesAlbumTitle = "Stitches"
let StitchCellReuseIdentifier = "StitchCell"
let CreateNewStitchSegueID = "CreateNewStitchSegue"
let StitchDetailSegueID = "StitchDetailSegue"

class StitchesViewController: UIViewController {
  
  @IBOutlet private var collectionView: UICollectionView!
  @IBOutlet private var noStitchView: UILabel!
  @IBOutlet private var newStitchButton: UIBarButtonItem!
  
  private var assetThumbnailSize: CGSize = .zero
  private var stitches: PHFetchResult<PHAsset>!
  private var stitchesCollection: PHAssetCollection!
  
  private var cellSize: CGSize {
    get {
      return (collectionView.collectionViewLayout as? UICollectionViewFlowLayout)?.itemSize ?? .zero
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
    PHPhotoLibrary.requestAuthorization { (status) in
      DispatchQueue.main.async {
        switch status {
        case .authorized:
          PHPhotoLibrary.shared().register(self)
          let options = PHFetchOptions()
          options.predicate = NSPredicate(format: "title = %@", StitchesAlbumTitle)
          let collections = PHAssetCollection.fetchAssetCollections(with: .album, subtype: .albumRegular, options: options)
          
          if collections.count > 0 {
            self.stitchesCollection = collections[0]
            self.stitches = PHAsset.fetchAssets(in: self.stitchesCollection, options: nil)
            self.collectionView.reloadData()
            self.updateNoStitchView()
          } else {
            self.createStitchesAlbum()
          }
        default:
          self.noStitchView.text = "Please grant Stitch photo access in Settings -> Privacy"
          self.noStitchView.isHidden = false
          self.newStitchButton.isEnabled = false
          self.showNoAccessAlert()
        }
      }
    }
  }
  
  deinit {
    PHPhotoLibrary.shared().unregisterChangeObserver(self)
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    // Calculate Thumbnail Size
    let scale = UIScreen.main.scale
    let cellSize = (collectionView.collectionViewLayout as? UICollectionViewFlowLayout)?.itemSize ?? .zero
    assetThumbnailSize = CGSize(width: cellSize.width * scale, height: cellSize.height * scale)
    collectionView.reloadData()
  }
  
  override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
    super.viewWillTransition(to: size, with: coordinator)
    collectionView.reloadData()
  }
  
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    if segue.identifier == CreateNewStitchSegueID,
      let nav = segue.destination as? UINavigationController,
      let dest = nav.viewControllers[0] as? AssetCollectionsViewController {
      dest.delegate = self
      dest.selectedAssets = []
    } else if segue.identifier == StitchDetailSegueID,
      let cell = sender as? UICollectionViewCell,
      let indexPath = collectionView.indexPath(for: cell),
      let dest = segue.destination as? StitchDetailViewController {
      dest.asset = stitches[indexPath.item]
    }
  }
  
  // MARK: - Private
  
  private func updateNoStitchView() {
    noStitchView.isHidden = (stitches == nil || (stitches.count > 0))
  }
  
  private func showNoAccessAlert() {
    let alert = UIAlertController(title: "No Photo Access",
                                  message: "Please grant Stitch photo access in Settings -> Privacy",
                                  preferredStyle: .alert)
    alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
    alert.addAction(UIAlertAction(title: "Settings", style: .default, handler: { _ in
      if let url = URL(string: UIApplication.openSettingsURLString) {
        UIApplication.shared.open(url, options: [:])
      }
    }))
    present(alert, animated: true, completion: nil)
  }
  
  private func createStitchesAlbum() {
    var assetPlaceholder: PHObjectPlaceholder?
    PHPhotoLibrary.shared().performChanges({
      let changeRequest = PHAssetCollectionChangeRequest.creationRequestForAssetCollection(withTitle: StitchesAlbumTitle)
      assetPlaceholder = changeRequest.placeholderForCreatedAssetCollection
    }) { (success, error) in
      guard let assetPlaceholder = assetPlaceholder, success else {
        return
      }
      let collections = PHAssetCollection.fetchAssetCollections(withLocalIdentifiers: [assetPlaceholder.localIdentifier], options: nil)
      if collections.count > 0 {
        self.stitchesCollection = collections[0]
        self.stitches = PHAsset.fetchAssets(in: self.stitchesCollection, options: nil)
      }
    }
  }
}

// MARK: - AssetPickerDelegate

extension StitchesViewController: AssetPickerDelegate {
  
  func assetPickerDidCancel() {
    dismiss(animated: true, completion: nil)
  }
  
  func assetPickerDidFinishPickingAssets(selectedAssets: [PHAsset])  {
    dismiss(animated: true, completion: nil)
    if selectedAssets.count > 0 {
      StitchHelper.createNewStitchWith(assets: selectedAssets, inCollection: stitchesCollection)
    }
  }
}

// MARK: - UICollectionViewDataSource

extension StitchesViewController: UICollectionViewDataSource {
  
  func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return stitches?.count ?? 0
  }
  
  func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    let cell =
      collectionView.dequeueReusableCell(withReuseIdentifier: StitchCellReuseIdentifier,
                                         for: indexPath as IndexPath) as! AssetCell
    cell.reuseCount = cell.reuseCount + 1
    let reuseCount = cell.reuseCount
    
    let asset = stitches[indexPath.item]
    PHImageManager.default().requestImage(for: asset, targetSize: cellSize, contentMode: .aspectFill, options: requestOptions) { (result, info) in
      if reuseCount == cell.reuseCount {
        cell.imageView.image = result
      }
    }
    return cell
  }
}

// MARK: - UICollectionViewDelegateFlowLayout

extension StitchesViewController: UICollectionViewDelegateFlowLayout {
  
  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
    var thumbsPerRow: Int
    switch collectionView.bounds.size.width {
    case 0..<400:
      thumbsPerRow = 2
    case 400..<800:
      thumbsPerRow = 3
    case 800..<1200:
      thumbsPerRow = 4
    default:
      thumbsPerRow = 3
    }
    let width = collectionView.bounds.size.width / CGFloat(thumbsPerRow)
    return CGSize(width: width, height: width)
  }
}

// MARK: - PHPhotoLibraryChangeObserver

extension StitchesViewController: PHPhotoLibraryChangeObserver {
  func photoLibraryDidChange(_ changeInstance: PHChange)  {
    DispatchQueue.main.async {
      if let collectionChanges = changeInstance.changeDetails(for: self.stitches) {
        self.stitches = collectionChanges.fetchResultAfterChanges
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

// MARK: - IndexSet extension

extension IndexSet {
  // Create an array of index paths from an index set
  func indexPaths(for section: Int) -> [IndexPath] {
    let indexPaths = map { (i) -> IndexPath in
      return IndexPath(item: i, section: section)
    }
    return indexPaths
  }
}
