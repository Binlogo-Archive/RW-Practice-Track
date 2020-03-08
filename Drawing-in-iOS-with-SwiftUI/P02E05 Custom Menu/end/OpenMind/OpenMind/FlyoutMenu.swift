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

struct FlyoutMenuOption {
  var image: Image
  var color: Color
  var action: () -> Void = {}
}

struct FlyoutMenu: View {
  let flyoutMenuOptions: [FlyoutMenuOption]
  let iconDiameter: CGFloat = 44
  let menuDiameter: CGFloat = 150
  var radius: CGFloat {
    return menuDiameter / 2
  }
  @State var isOpen = false
  
    var body: some View {
      ZStack {
        Circle()
          .foregroundColor(.pink)
          .opacity(0.1)
          .frame(width: isOpen ? menuDiameter + iconDiameter : 0)
        
        ForEach(flyoutMenuOptions.indices) { index in
          self.drawOption(index: index)
        }
        
        FlyoutMenuMain(isOpen: self.$isOpen)
      }
    }
  
  func drawOption(index: Int) -> some View {
    let angle = .pi / 4 * CGFloat(index) - .pi / 1.7
    let offset = CGSize(width: cos(angle) * radius,
                        height: sin(angle) * radius)
    let option = flyoutMenuOptions[index]
    return Button(action: {
      option.action()
    }) {
      ZStack {
        Circle()
          .foregroundColor(option.color)
        option.image
          .font(.system(size: 20, weight: .medium))
          .foregroundColor(.white)
      }
    }
  .offset(offset)
    .frame(width: 44)
    .scaleEffect(self.isOpen ? 1.0 : 0.01)
  }
}

struct FlyoutMenuMain: View {
  @Binding var isOpen: Bool
  
    var body: some View {
      Button(action: {
        withAnimation(.spring()) {
          self.isOpen.toggle()
        }
        self.endTextEditing()
      }) {
        ZStack {
          Circle()
            .foregroundColor(.red)
          Image(systemName: "plus")
            .foregroundColor(.white)
            .font(.system(size: 20, weight: .medium))
            .rotationEffect(isOpen ? Angle.degrees(45) : Angle.degrees(0))
        }
      }
      .frame(width: 44, height: 44)
    }
}

struct FlyoutMenu_Previews: PreviewProvider {
  static var flyoutMenuOptions: [FlyoutMenuOption] = [
    FlyoutMenuOption(image: Image(systemName: "trash"),
                     color: .blue),
    FlyoutMenuOption(image: Image(systemName: "link"),
                     color: .purple)
  ]
    static var previews: some View {
        FlyoutMenu(flyoutMenuOptions: flyoutMenuOptions)
    }
}
