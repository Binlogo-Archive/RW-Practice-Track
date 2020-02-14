//
/// Copyright (c) 2019 Razeware LLC
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

import SwiftUI

struct Shapes: View {
    var body: some View {
        Heart()
          .stroke(style: StrokeStyle(lineWidth: 10,
                                     lineCap: .round))
      .padding()
    }
}

struct Heart: Shape {
  func path(in rect: CGRect) -> Path {
    var path = Path()
    path.addArc(center: CGPoint(x: rect.width * 0.25,
                                y: rect.height * 0.25),
                radius: rect.width * 0.25,
                startAngle: Angle(degrees: 0),
                endAngle: Angle(degrees: 180),
                clockwise: true)
    
    let control1 = CGPoint(x: 0,
                           y: rect.height * 0.8)
    let control2 = CGPoint(x: rect.width * 0.25,
                           y: rect.height * 0.95)
    path.addCurve(to: CGPoint(x: rect.width * 0.5,
                              y: rect.height),
                  control1: control1,
                  control2: control2)
    
    var transform = CGAffineTransform(translationX: rect.width, y: 0)
    transform = transform.scaledBy(x: -1, y: 1)
    path.addPath(path, transform: transform)
    
    return path
  }
}
struct Shapes_Previews: PreviewProvider {
    static var previews: some View {
        Shapes()
    }
}
