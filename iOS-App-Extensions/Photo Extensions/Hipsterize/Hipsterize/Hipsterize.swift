//
//  Hipsterize.swift
//  Hipsterize
//
//  Created by Dylan Wang on 2020/1/5.
//  Copyright © 2020 WangXingbin. All rights reserved.
//

import UIKit

enum HipsterElementType: String {
  case Glasses1 = "glasses1"
  case Glasses2 = "glasses2"
  case Fedora1 = "fedora1"
}

struct HipsterElement: CustomStringConvertible {
  var type: HipsterElementType
  var center: CGPoint
  var width: CGFloat
  var transform: CGAffineTransform

  var description: String {
    return "\(type.rawValue) - center \(center) width \(width)"
  }
}

class Hipsterize {
  let image: UIImage

  init(image: UIImage) {
    self.image = image.normalized()
  }

  func processedImage() -> UIImage {
    let imageView = UIImageView(image: image)
    let ciImage = CIImage(image: image)

    let context = CIContext()
    let detector = CIDetector(ofType: CIDetectorTypeFace, context: context, options: [CIDetectorAccuracy: CIDetectorAccuracyHigh])
    let faces = detector?.features(in: ciImage!)

    var counter = 0
    for face in faces as! [CIFaceFeature] {
        let faceBounds = convertedRectForImage(image, originalRect: face.bounds)
        let overlayWidth = face.bounds.width
      var eyeAngle: CGFloat = 0

      if (face.hasLeftEyePosition && face.hasRightEyePosition) {
        let rightEyePosition = convertedPointForImage(image, originalPoint: face.rightEyePosition)
        let leftEyePosition = convertedPointForImage(image, originalPoint: face.leftEyePosition)
        eyeAngle = atan2(rightEyePosition.y - leftEyePosition.y, rightEyePosition.x - leftEyePosition.x)

        let eyeCenter = CGPoint(x: (rightEyePosition.x + leftEyePosition.x) / 2.0, y: (rightEyePosition.y + leftEyePosition.y) / 2.0)

        counter += Int(arc4random_uniform(2))
        let glassesView = UIImageView(image: UIImage(named: counter % 2 == 0 ? "glasses1" : "glasses2"))
        glassesView.contentMode = .scaleAspectFit
        glassesView.frame = CGRect(x: 0, y: 0, width: overlayWidth, height: overlayWidth / (glassesView.image!.size.width/glassesView.image!.size.height))
        glassesView.center = eyeCenter
        glassesView.transform = CGAffineTransform(rotationAngle: eyeAngle)
        imageView.addSubview(glassesView)
      }

      counter += Int(arc4random_uniform(2))
      let fedoraView = UIImageView(image: UIImage(named: counter % 2 == 0 ? "fedora1" : "fedora2"))
        fedoraView.contentMode = .scaleAspectFit
      fedoraView.frame = CGRect(x: 0, y: 0, width: overlayWidth*1.2, height: overlayWidth*1.2 / (fedoraView.image!.size.width/fedoraView.image!.size.height))


        let rectTopCenter = CGPoint(x: faceBounds.origin.x + faceBounds.width/2, y: faceBounds.origin.y - fedoraView.frame.height/3)
        let faceCenter = CGPoint(x: faceBounds.origin.x + faceBounds.width/2, y: faceBounds.origin.y + faceBounds.height/2)

      let s = sin(eyeAngle)
      let c = cos(eyeAngle)
      let xAngle = c * (rectTopCenter.x-faceCenter.x) - s * (rectTopCenter.y-faceCenter.y)
      let yAngle = (s * (rectTopCenter.x-faceCenter.x) + c * (rectTopCenter.y-faceCenter.y))
      let rotatedPoint = CGPoint(x: xAngle + faceCenter.x,
        y: yAngle + faceCenter.y)

      fedoraView.center = rotatedPoint
        fedoraView.transform = CGAffineTransform(rotationAngle: eyeAngle)
      imageView.addSubview(fedoraView)
    }

    UIGraphicsBeginImageContextWithOptions(image.size, false, image.scale)
    imageView.layer.render(in: UIGraphicsGetCurrentContext()!)
    let processedImage = UIGraphicsGetImageFromCurrentImageContext()
    UIGraphicsEndImageContext()
    return processedImage ?? image
  }

  private func convertedRectForImage(_ image: UIImage, originalRect: CGRect) -> CGRect {
    var transform = CGAffineTransform(scaleX: 1, y: -1)
    transform = transform.translatedBy(x: 0, y: -image.size.height);

    return originalRect.applying(transform)
  }

  private func convertedPointForImage(_ image: UIImage, originalPoint: CGPoint) -> CGPoint {
    var convertedPoint = originalPoint
    let imageWidth = image.size.width
    let imageHeight = image.size.height

    switch (image.imageOrientation) {
    case .up:
      convertedPoint.x = originalPoint.x;
      convertedPoint.y = imageHeight - originalPoint.y;
    case .down:
      convertedPoint.x = imageWidth - originalPoint.x;
      convertedPoint.y = originalPoint.y;
    case .left:
      convertedPoint.x = imageWidth - originalPoint.y;
      convertedPoint.y = imageHeight - originalPoint.x;
    case .right:
      convertedPoint.x = originalPoint.y;
      convertedPoint.y = originalPoint.x;
    case .upMirrored:
      convertedPoint.x = imageWidth - originalPoint.x;
      convertedPoint.y = imageHeight - originalPoint.y;
    case .downMirrored:
      convertedPoint.x = originalPoint.x;
      convertedPoint.y = originalPoint.y;
    case .leftMirrored:
      convertedPoint.x = imageWidth - originalPoint.y;
      convertedPoint.y = originalPoint.x;
    case .rightMirrored:
      convertedPoint.x = originalPoint.y;
      convertedPoint.y = imageHeight - originalPoint.x;
    @unknown default:
        fatalError()
    }
    return convertedPoint
  }
}

private extension UIImage {
    func normalized() -> UIImage {
        if imageOrientation == .up { return self }

        UIGraphicsBeginImageContextWithOptions(size, false, scale)
        draw(in: CGRect(origin: CGPoint(x: 0, y: 0), size: size))
        let normalizedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return normalizedImage ?? self
    }
}
