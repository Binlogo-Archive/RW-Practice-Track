# iOS Photo Framework

Notes from [video course](https://www.raywenderlich.com/7910383-ios-photos-framework) of iOS Photo Framework. 



## Environment

 Swift 5.1, iOS 13.2, Xcode 11.2



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



## P02E01 Create Collage Collection & Data Source

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



## P02E02 Create and Display Collage Assets

Create a new photo asset with a collage of the selected images, save it to the Stitches album, then load a high quality version of the image for display.

* Create new stitch(a collage)
  * Calculate placement rects
  * Create context to draw images
  * `PHImageRequestOptions`
  * Draw each image into their rect
    * `PHImageManager.default().requetImage`
* Save the collage to the ablum
  * `PHPhotoLibrary.shared().performChanges`
  * `PHAssetChangeRequest.creationRequestForAsset`
    * `.placeholderForCreatedAsset`
    * `.contentEditingOutput`
  * `PHContentEditingOutput`
    * `.adjustmentData`
    * Write image to url: `.renderedContentURL`
  * `PHAssetCollectionChangeRequest`
    * `addAssets`
* Display the collage image
* Q: How to observe Photo Library changes?



## Copyright

The source materials from [raywenderlich.com/](https://www.raywenderlich.com/) are Copyright (c) 2020 Razeware LLC