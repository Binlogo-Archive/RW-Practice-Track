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
          PHPhotoLibrary.shared().register(self)
          self.fetchCollections()
          self.tableView.reloadData()
        default:
          self.showNoAccessAlert()
        }
      }
    }
  }
  
  deinit {
    PHPhotoLibrary.shared().unregisterChangeObserver(self)
  }
  
  override func viewWillAppear(_ animated: Bool)  {
    super.viewWillAppear(animated)
    tableView.reloadData()
  }
  
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    guard let destination = segue.destination as? AssetsViewController,
      let cell = sender as? UITableViewCell,
      let indexPath = tableView.indexPath(for: cell) else {
        return
    }
    destination.selectedAssets = selectedAssets
    destination.title = cell.textLabel?.text
    destination.delegate = self
    
    let options = PHFetchOptions()
    options.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: true)]
    
    switch indexPath.section {
    case 0:
      destination.assetsFetchResults = nil
    case 1:
      if indexPath.row == 0 {
        destination.assetsFetchResults = PHAsset.fetchAssets(with: options)
      } else if let favorites = userFavorites?[indexPath.row - 1] {
        destination.assetsFetchResults = PHAsset.fetchAssets(in: favorites, options: options)
      }
    case 2:
      if let album = userAlbums?[indexPath.row] {
        destination.assetsFetchResults = PHAsset.fetchAssets(in: album, options: options)
      }
    default:
      break
    }
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
    return sectionNames.count
  }
  
  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    switch section {
    case 0:
      return 1
    case 1:
      return 1 + (userFavorites?.count ?? 0)
    case 2:
      return userAlbums?.count ?? 0
    default:
      return 0
    }
  }
  
  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell =
      tableView.dequeueReusableCell(withIdentifier: AssetCollectionCellReuseIdentifier,
                                    for: indexPath)
    cell.detailTextLabel?.text = ""
    switch indexPath.section {
    case 0:
      cell.textLabel?.text = "Selected"
      cell.detailTextLabel?.text = "\(selectedAssets.count)"
    case 1:
      if indexPath.row == 0 {
        cell.textLabel?.text = "All Photos"
      } else if let favorites = userFavorites?[indexPath.row - 1] {
        cell.textLabel?.text = favorites.localizedTitle
        if favorites.estimatedAssetCount != NSNotFound {
          cell.detailTextLabel?.text = "\(favorites.estimatedAssetCount)"
        }
      }
    case 2:
      if let album = userAlbums?[indexPath.row] {
        cell.textLabel?.text = album.localizedTitle
        if album.estimatedAssetCount != NSNotFound {
          cell.detailTextLabel?.text = "\(album.estimatedAssetCount)"
        }
      }
    default:
      break
    }
    return cell
  }
}

// MARK: - PHPhotoLibraryChangeObserver

extension AssetCollectionsViewController: PHPhotoLibraryChangeObserver {
  func photoLibraryDidChange(_ changeInstance: PHChange) {
    DispatchQueue.main.async {
      var updatedFetchResults = false
      if let userAlbums = self.userAlbums,
        let changes = changeInstance.changeDetails(for: userAlbums) {
        self.userAlbums = changes.fetchResultAfterChanges
        updatedFetchResults = true
      }
      if let userFavorites = self.userFavorites,
        let changes = changeInstance.changeDetails(for: userFavorites) {
        self.userFavorites = changes.fetchResultAfterChanges
        updatedFetchResults = true
      }
      if updatedFetchResults {
        self.tableView.reloadData()
      }
    }
  }
}

extension AssetCollectionsViewController: SelectedAssetsDelegate {
  func updateSelectedAssets(_ assets: [PHAsset]) {
    selectedAssets = assets
    tableView.reloadData()
  }
}
