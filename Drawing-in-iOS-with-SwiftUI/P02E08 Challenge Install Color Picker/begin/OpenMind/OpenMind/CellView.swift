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

struct CellView: View {
  @EnvironmentObject var cellData: CellData
  @EnvironmentObject var modalViews: ModalViews
  
  
  let cell: Cell
  @State private var text: String = ""
  @State private var offset: CGSize = .zero
  @State private var currentOffset: CGSize = .zero
  
  static var crayonImage: Image {
    let config =
      UIImage.SymbolConfiguration(pointSize: 20,
                                  weight: .medium,
                                  scale: .medium)
    return Image(uiImage: UIImage(named: "crayon")!.withConfiguration(config))
  }
  
  func setupOptions() -> [FlyoutMenuOption] {
    let flyoutMenuOptions: [FlyoutMenuOption] = [
      FlyoutMenuOption(image: Image(systemName: "trash"),
                       color: .blue,
                       action: {
                        self.cellData.delete(cell: self.cell)
      }),
      FlyoutMenuOption(image: Image(systemName: "square.on.circle"),
                       color: .green,
                       action: {
                        self.modalViews.showShapes = true
      }),
      FlyoutMenuOption(image: Image(systemName: "link"),
                       color: .purple),
      FlyoutMenuOption(image: Self.crayonImage,
                       color: .orange)
    ]
    return flyoutMenuOptions
  }
  
  var isSelected: Bool {
    cell == cellData.selectedCell
  }
  var body: some View {
    let flyoutMenuOptions = setupOptions()
    let drag = DragGesture()
      .onChanged { drag in
        self.offset = self.currentOffset + drag.translation
    }
    .onEnded { drag in
      self.offset = self.currentOffset + drag.translation
      self.currentOffset = self.offset
    }
    return ZStack {
      cell.shapeType.shape
        .foregroundColor(.white)
      TextField("Enter cell text", text: $text)
        .padding()
        .lineLimit(nil)
        .multilineTextAlignment(.center)
      cell.shapeType.shape
        .stroke(isSelected ? Color.orange : cell.color,
                lineWidth: 3)
      if isSelected {
        FlyoutMenu(flyoutMenuOptions: flyoutMenuOptions)
          .offset(x: cell.size.width / 2,
                  y: -cell.size.height / 2)
      }
    }
    .frame(width: cell.size.width,
           height: cell.size.height)
      .offset(cell.offset + offset)
      .onAppear {
        self.text = self.cell.text
    }
    .onTapGesture {
      self.cellData.selectedCell = self.cell
    }
    .simultaneousGesture(drag)
  }
}

struct CellView_Previews: PreviewProvider {
  static var previews: some View {
    CellView(cell: Cell())
      .previewLayout(.sizeThatFits)
      .padding()
      .environmentObject(CellData())
  }
}
