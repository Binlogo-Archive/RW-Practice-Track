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

