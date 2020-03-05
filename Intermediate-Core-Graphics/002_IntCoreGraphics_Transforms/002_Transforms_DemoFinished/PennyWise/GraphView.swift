/*
* Copyright (c) 2016 Razeware LLC
*
* Permission is hereby granted, free of charge, to any person obtaining a copy
* of this software and associated documentation files (the "Software"), to deal
* in the Software without restriction, including without limitation the rights
* to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
* copies of the Software, and to permit persons to whom the Software is
* furnished to do so, subject to the following conditions:
*
* The above copyright notice and this permission notice shall be included in
* all copies or substantial portions of the Software.
*
* THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
* IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
* FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
* AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
* LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
* OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
* THE SOFTWARE.
*/
import UIKit

@IBDesignable

class GraphView: UIView {
  let chartColors = [
    UIColor(red: 1.0, green: 107/255, blue: 107/255, alpha: 1.0),
    UIColor(red: 155/255, green: 224/255, blue: 172/255, alpha: 1.0),
    UIColor(red: 136/255, green: 161/255, blue: 212/255, alpha: 1.0),
    UIColor(red: 1.0, green: 172/255, blue: 99/255, alpha: 1.0),
    UIColor(red: 135/255, green: 218/255, blue: 230/255, alpha: 1.0),
    UIColor(red: 250/255, green: 250/255, blue: 147/255, alpha: 1.0)]

  override func drawRect(rect:CGRect) {
    let context = UIGraphicsGetCurrentContext()
    
    let totalSpent = categories.reduce(0,
      combine: {$0 + $1.spent})
    guard totalSpent > 0 else { return }
    
    let diameter = min(bounds.width, bounds.height)
    let margin:CGFloat = 20
    
    let circle = UIBezierPath(ovalInRect:
      CGRect(x:0, y:0,
        width:diameter,
        height:diameter
        ).insetBy(dx: margin, dy: margin))
    
    let transform = CGAffineTransformMakeTranslation(bounds.width/2 - diameter/2 ,0)
    
    circle.applyTransform(transform)
    
    let workingCategories = categories.filter({ $0.spent > 0 })
    
    for (index, _) in workingCategories.enumerate() {
    
      let percent = CGFloat(workingCategories[index].spent/totalSpent)
      let angle = percent * 2 * π
      
      print(workingCategories[index].name, workingCategories[index].spent, round(percent * 100))
      
      let slice = UIBezierPath()
      
      let radius = diameter / 2 - margin
      let centerPoint = center
      
      slice.moveToPoint(centerPoint)
      slice.addLineToPoint(CGPoint(x:centerPoint.x + radius, y:centerPoint.y))
      slice.addArcWithCenter(centerPoint, radius:radius, startAngle: 0, endAngle: angle, clockwise: true)
      slice.closePath()
      
      chartColors[index].setFill()
      slice.fill()
      
      CGContextTranslateCTM(context, centerPoint.x, centerPoint.y)
      CGContextRotateCTM(context, angle)
      CGContextTranslateCTM(context, -centerPoint.x, -centerPoint.y)
      
    }
    
    
    circle.stroke()
    
  }
  
  
  
  
  
}

