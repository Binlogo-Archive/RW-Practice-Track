# [Intermediate Core Graphics](https://www.raywenderlich.com/3198-intermediate-core-graphics)

![](https://files.betamax.raywenderlich.com/attachments/collections/27/CG-Int-FeaturedBanner%402x.png)

## Gradients

Learn how to create gradients to make your app more appealing.

* extension UIView
  * `drawGradient(startColor: UIColor, endColor: UIColor, startPoint: CGPoint, endPoint: CGPoint)`
* CGColorSpaceCreateDeviceRGB()
* CGGradientCreateWithColors
* UIGraphicsGetCurrentContext()
* CGContextDrawLinearGradient
* UIBezierPath
  * addClip()
* CGPathCreateCopyByStrokingPath



## Transform

Learn about transforms and how to rotate and scale paths and contexts. Become a master of the Context Transformation Matrix.

* What is a Transform?
  * A matrix
  * holds position, scale and rotation
  * UIView: **CGAffineTransform transform** property
  * Context: **CGContextGetCTM** function
* Demo: A pi chart
* UIBezierPath.applyTransform
* CGContextGetCTM
  * ⚠️ total context



## Shadows

Learn about how to draw shadows and composite them using transparency layers.

* Not UIKit wrapped
  * CGContextSetShadowWithColor(_:_:_:)
* color
* shadow offset
* blur radius
* Shadow with Stroke
* Transparency Layers
  * CGContextBeginTransparencyLayer
  * CGContextEndTransparencyLayer
* Demo: Add shadow to pi chart
* Save and restore context
  * CGContextSaveGState
  * CGContextRestoreGState



## Drawing Text and Images

Learn about drawing text and images into the context.

* Text and Image Drawing
  * drawAtPoint(_:withAttributes:)
  * drawInRect(_:withAttributes:)
* Sizing Text
  * sizeWithAttributes(:)
* Patterns
  * UIColor(patternImage:)
* Demo: Draw category keys to pi chart
  * Save and restore context
    * CGContextSaveGState
    * CGContextRestoreGState
  * Draw Text
  * Draw Image
    * UIGraphicsBeginImageContextWithOptions
    * UIGraphicsGetImageFromCurrentImageContext()
    * UIGraphicsEndImageContext()
  * drawAsPatternInRect
  * UIColor(patternImage:)
    * setFill()
  * UIRectFill()



## PDF Printing

Create a PDF file. We’ll create a budget report that you could then share.

* PDF: Portable Document Format

  * Looks like a printed document
  * Indepentent of operating systems and hardware
  * `UIGraphicsBeginPDFContextToData(_:_:_:_:)`
  * `UIGraphicsBeginPDFContextToFile(_:_:_:_:)`

* PDF Creation

  * documentInfo: [String: String], kCGPDFContextXXXX
  * `UIGraphicsBeginPDFContextToFile(_:_:_:_:)`
  * `UIGraphicsBeginPDFPage()`
  * `UIGraphicsEndPDFContext()`

* Reading PDFs

  * Use UIWebView
    * webView.loadRequest

* Rendering PDFs

  * CGPDFDocumentCreateWithURL
  * CGPDFDocumentGetNumberOfPages

  * CGPDFDocuemtnGetPage

* Draw PDF

  * CGContextTranslateCTM() + CGContextScaleCTM
  * CGContextDrawPDFPage()

* Demo: Create a report

  * UIView.layer.renderInContext