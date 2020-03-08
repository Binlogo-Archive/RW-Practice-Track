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

struct AnyShape: Shape {
  private let path: (CGRect) -> Path
  
  init<T: Shape> (_ shape: T) {
    path = { rect in
      return shape.path(in: rect)
    }
  }
  
  func path(in rect: CGRect) -> Path {
    return path(rect)
  }
}

enum ShapeType: CaseIterable {
  case rectangle
  case ellipse
  case diamond
  case chevron
  case heart
  case roundedRect
  case empty
  
  var shape: some Shape {
    switch self {
    case .rectangle:
      return Rectangle().anyShape()
    case .ellipse:
      return Ellipse().anyShape()
    case .chevron:
      return Chevron().anyShape()
    case .diamond:
      return Diamond().anyShape()
    case .heart:
      return Heart().anyShape()
    case .roundedRect:
      return RoundedRectangle(cornerRadius: 30).anyShape()
    case .empty:
      return Path().anyShape()
    }
  }
}

extension Shape {
  func anyShape() -> AnyShape {
    return AnyShape(self)
  }
}

struct Shapes: View {
  var body: some View {
    let style = StrokeStyle(lineWidth: 10, lineJoin: .round)
    return VStack {
      Heart()
        .stroke(style: style)
        .padding()
      Chevron()
        .stroke(lineWidth: 10)
        .padding()
      Diamond()
        .stroke(style: style)
        .padding()
    }
  }
}

struct Chevron: Shape {
  func path(in rect: CGRect) -> Path {
    Path { path in
      path.addLines([
        .zero,
        CGPoint(x: rect.width * 0.75, y: 0),
        CGPoint(x: rect.width, y: rect.height * 0.5),
        CGPoint(x: rect.width * 0.75, y: rect.height),
        CGPoint(x: 0, y: rect.height),
        CGPoint(x: rect.width * 0.25, y: rect.height * 0.5)
      ])
      path.closeSubpath()
    }
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

struct Diamond: Shape {
  func path(in rect: CGRect) -> Path {
    Path { path in
      let width = rect.width
      let height = rect.height
      
      path.addLines( [
        CGPoint(x: width / 2, y: 0),
        CGPoint(x: width, y: height / 2),
        CGPoint(x: width / 2, y: height),
        CGPoint(x: 0, y: height / 2)
      ])
      path.closeSubpath()
    }
  }
  
  
}

struct Shapes_Previews: PreviewProvider {
  static var previews: some View {
    Shapes()
  }
}
