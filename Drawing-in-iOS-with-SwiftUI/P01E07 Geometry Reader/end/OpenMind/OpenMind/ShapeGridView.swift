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

struct ShapeGridView: View {
    var body: some View {
      UITableView.appearance().separatorColor = .clear
      let cellSize = CGSize(width: 100, height: 100)
      return GeometryReader { geometry in
        List {
          ShapesGrid(allShapes: ShapeType.allCases,
                     cellSize: cellSize,
                   viewSize: geometry.size)
            .listRowInsets(EdgeInsets(top: 0, leading: 0,
                                      bottom: 0, trailing: 0))
        }
      }
    }
}

struct ShapesGrid: View {
  let allShapes: [ShapeType]
  let cellSize: CGSize
  let viewSize: CGSize
  let padding: CGFloat = 10
  var columns: Int {
    var columns = viewSize.width / cellSize.width
    while (columns * cellSize.width + padding * columns) > viewSize.width {
      columns -= 1
    }
    return Int(columns)
  }
  
  var finalArray: [[ShapeType]] {
    var array: [[ShapeType]] = []
    var rowArray: [ShapeType] = []
    
    for i in 0..<allShapes.count {
      if i % columns == 0 {
        if i != 0 {
          array.append(rowArray)
        }
        rowArray = []
      }
      rowArray.append(allShapes[i])
    }
    while rowArray.count < columns {
      rowArray.append(ShapeType.empty)
    }
    array.append(rowArray)
    return array
  }
  var body: some View {
    ForEach(0..<finalArray.count) { rowIndex in
      HStack(spacing: 0) {
        ForEach(0..<self.finalArray[rowIndex].count) { columnIndex in
          self.finalArray[rowIndex][columnIndex].shape
          .stroke()
            .frame(width: self.cellSize.width,
                   height: self.cellSize.height)
            .padding(self.padding)
        }
      }
      .frame(width: self.viewSize.width)
    }
  }
}

struct ShapeGridView_Previews: PreviewProvider {
    static var previews: some View {
        ShapeGridView()
    }
}
