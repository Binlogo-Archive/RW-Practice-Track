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

struct DrawingPath: Identifiable {
  var id: UUID = UUID()
  var path = Path()
  var points: [CGPoint] = []
  var color: Color = .black
  
  mutating func addLine(to point: CGPoint,
                        color: Color) {
    if path.isEmpty {
      path.move(to: point)
      self.color = color
    } else {
      path.addLine(to: point)
    }
    points.append(point)
  }
  
  mutating func smoothLine() {
    var newPath = Path()
    newPath.interpolatePointsWithHermite(interpolationPoints: points)
    path = newPath
  }
  
}

struct DrawingPadSwiftUI: View {
  @State private var paths: [DrawingPath] = []
  @State private var drawingPath = DrawingPath()
  
  @State private var pickedColor: PickedColor = .black
  
    var body: some View {
      let drag = DragGesture(minimumDistance: 0)
        .onChanged { stroke in
          self.drawingPath.addLine(to: stroke.location,
                                   color: self.pickedColor.color)
      }
      .onEnded { stroke in
        self.drawingPath.smoothLine()
        if !self.drawingPath.path.isEmpty {
          self.paths.append(self.drawingPath)
        }
        self.drawingPath = DrawingPath()
      }
      return VStack {
        ZStack {
          Color.white
            .edgesIgnoringSafeArea(.all)
          .gesture(drag)
          ForEach(paths) { drawingPath in
            drawingPath.path
              .stroke(drawingPath.color)
          }
          drawingPath.path.stroke(drawingPath.color)
        }
        Divider()
        ColorPicker(pickedColor: $pickedColor)
          .frame(height: 80)
      }
    }
}

struct DrawingPadSwiftUI_Previews: PreviewProvider {
    static var previews: some View {
        DrawingPadSwiftUI()
    }
}
