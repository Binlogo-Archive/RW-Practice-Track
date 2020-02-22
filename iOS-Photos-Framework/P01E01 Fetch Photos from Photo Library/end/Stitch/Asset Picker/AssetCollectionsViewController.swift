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

protocol AssetPickerDelegate {
  func assetPickerDidFinishPickingAssets(selectedAssets: [PHAsset])
  func assetPickerDidCancel()
}

class AssetCollectionsViewController: UITableViewController {
  
  var delegate: AssetPickerDelegate?
  var selectedAssets: [PHAsset] = []
  
  let AssetCollectionCellReuseIdentifier = "AssetCollectionCell"
  private let sectionNames = ["", "", "Albums"]
  private var userAlbums: PHFetchResult<PHAssetCollection>?
  private var userFavorites: PHFetchResult<PHAssetCollection>?
  
  // MARK: - UIViewController
  
  override func viewDidLoad() {
    super.viewDidLoad()
    PHPhotoLibrary.requestAuthorization { (status) in
      DispatchQueue.main.async {
        switch status {
        case .authorized:
          self.fetchCollections()
          self.tableView.reloadData()
        default:
          self.showNoAccessAlert()
        }
      }
    }
  }
  
  override func viewWillAppear(_ animated: Bool)  {
    super.viewWillAppear(animated)
    tableView.reloadData()
  }
  
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {

  }
  
  func fetchCollections() {
    if let albums = PHCollectionList.fetchTopLevelUserCollections(with: nil) as? PHFetchResult<PHAssetCollection> {
      userAlbums = albums
    }
    userFavorites = PHAssetCollection.fetchAssetCollections(with: .smartAlbum, subtype: .smartAlbumFavorites, options: nil)
  }
  
  private func showNoAccessAlert() {
    let alert = UIAlertController(title: "No Photo Access",
                                  message: "Please grant Stitch photo access in Settings -> Privacy",
                                  preferredStyle: .alert)
    alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { _ in
      self.cancelPressed(self)
    }))
    alert.addAction(UIAlertAction(title: "Settings", style: .default, handler: { _ in
      if let url = URL(string: UIApplication.openSettingsURLString) {
        UIApplication.shared.open(url, options: [:])
      }
    }))
    present(alert, animated: true, completion: nil)
  }
  
  // MARK: - Actions
  
  @IBAction func donePressed(_ sender: AnyObject) {
    delegate?.assetPickerDidFinishPickingAssets(selectedAssets: selectedAssets)
  }
  
  @IBAction func cancelPressed(_ sender: AnyObject) {
    delegate?.assetPickerDidCancel()
  }
}

// MARK: - UITableViewDataSource

extension AssetCollectionsViewController {
  
  override func numberOfSections(in tableView: UITableView) -> Int {
    return 0
  }
  
  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return 0
  }
  
  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell =
      tableView.dequeueReusableCell(withIdentifier: AssetCollectionCellReuseIdentifier,
                                    for: indexPath)
    return cell
  }
}

// MARK: - PHPhotoLibraryChangeObserver

extension AssetCollectionsViewController: PHPhotoLibraryChangeObserver {
  func photoLibraryDidChange(_ changeInstance: PHChange) {

  }
}
