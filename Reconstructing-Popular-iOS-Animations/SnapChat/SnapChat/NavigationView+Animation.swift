//
//  NavigationView+Animation.swift
//  SnapChat
//
//  Created by Dylan Wang on 2020/1/4.
//  Copyright © 2020 WangXingbin. All rights reserved.
//

import UIKit

extension NavigationView {
    
    func animateIconColor(offset: CGFloat) {
      var iconPercent = (offset - 0.2) / (0.7 - 0.2)
      iconPercent = min(max(iconPercent, 0), 1)
      chatIconWhiteView.alpha = 1 - iconPercent
      chatIconGrayView.alpha = iconPercent
      storiesIconWhiteView.alpha = chatIconWhiteView.alpha
      storiesIconGrayView.alpha = chatIconGrayView.alpha
    }

    func animateIconPosition(offset: CGFloat) {
      // Line the controls up along the bottom
      let finalDistanceFromBottom: CGFloat = 25.0
      var distance = cameraButtonBottomConstraintConstant - finalDistanceFromBottom
      cameraButtonBottomConstraint.constant = cameraButtonBottomConstraintConstant - (distance * offset)
      distance = chatIconBottomConstraintConstant - finalDistanceFromBottom
      chatIconBottomConstraint.constant = chatIconBottomConstraintConstant - (distance * offset)
    }

    func animateIconScale(offset: CGFloat) {
      // Scale the controls using width constraints
      let finalWidthScale: CGFloat = cameraButtonWidthConstraintConstant * 0.2
      cameraButtonWidthConstraint.constant = cameraButtonWidthConstraintConstant - (finalWidthScale * offset)
      let scale = chatIconWidthConstraintConstant * 0.2
      chatIconWidthConstraint.constant = chatIconWidthConstraintConstant - (scale * offset)
    }

    func animateIconCenter(offset: CGFloat) {
      // Move chat and story icons towards the center
      // Subtract the original multiplier and add in the new
      // multiplier as constant values

      // Because the constraint multiplier is read only,
      // to change the layout, you have to use the constant.
      // You calculate the constant less the multiplier.
      // The original constraint multiplier is approx 0.2 of half the width,
      // so if the width = 375, the center would be 37.5

      // The transformed center should be 0.27 (27%) of bounds width,
      // so the new multiplier should be 0.54

      let originalMultiplier = chatIconHorizontalConstraint.multiplier * bounds.width * 0.5
      let newMultiplier = (bounds.width * 0.54 * 0.5) - originalMultiplier
      chatIconHorizontalConstraint.constant = newMultiplier * offset
      storiesIconHorizontalConstraint.constant = -newMultiplier * offset
    }

    func animateIconText(offset: CGFloat) {

      // text alphas out within 30%
      let iconTextPercent = offset / 0.3
      chatIconText.alpha = 1 - iconTextPercent
      storiesIconText.alpha = chatIconText.alpha

      // Move the text towards the center
      chatIconTextHorizontalConstraint.constant =
        chatIconHorizontalConstraint.constant
      chatIconTextBottomConstraint.constant =
        chatIconBottomConstraint.constant - 26
      storiesIconTextHorizontalConstraint.constant =
        storiesIconHorizontalConstraint.constant
    }

    func animateBottomBar(percent: CGFloat) {
      // Controller Indicator Line
      let offset = abs(percent)
      let scaleTransform = CGAffineTransform(scaleX: offset, y: 1)
      let distance = 0.23 * bounds.width

      // use percent as it has the correct sign
      let transform =
        indicatorTransform.translatedBy(x: distance * percent,
                                        y: 0)
      indicator.transform = transform.concatenating(scaleTransform)
      indicator.alpha = offset
    }

}
