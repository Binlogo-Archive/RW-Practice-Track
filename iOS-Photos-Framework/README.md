# iOS Photo Framework

Notes from [video course](https://www.raywenderlich.com/7910383-ios-photos-framework) of iOS Photo Framework.



## Covered concepts

- Requesting photo library permissions
- Fetching photo assets, asset collections and collection lists from device library
- Populating table view and collection view using library's photos and albums as data source
- Using photo image request options, ex. sort descriptors, delivery mode, network access allowed, etc.
- Loading asset image content
- Caching images using PHCachingImageManager
- Creating photo albums
- Editing assets
- Observing & responding to photo library changes



## Create Collage Collection & Data Source

Create a photo album for the collages (i.e. "Stitches") or fetch the album if it already exists, then set up a collection view to display that album's images.

* `PHPhotoLibrary.requestAuthrization`
  * Use main queue if update the UI
* `PHFetchOptions`
  * `.predicate`
* `PHAssetCollection.fetchAssetCollections`
* `PHAsset.fetchAssets`
* Handle no data update
* Create albums if needed
  * `PHPhotoLibrary.shared().performChanges`
  * `PHAssetCollectionChangeRequest.creationRequestForAssetCollection`
    * `.placeholderForCreatedAssetCollection`
  * Update data & setup view in creating completion
* Setup the collection view to display the album's images



