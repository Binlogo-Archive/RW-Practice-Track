//
//  NavigationView.swift
//  SnapChat
//
//  Created by Dylan Wang on 2020/1/4.
//  Copyright © 2020 WangXingbin. All rights reserved.
//

import UIKit

class NavigationView: UIView {
    
    @IBOutlet var cameraButtonView: UIView!
    @IBOutlet var cameraButtonWhiteView: UIImageView!
    @IBOutlet var cameraButtonGrayView: UIImageView!
    @IBOutlet var cameraButtonWidthConstraint: NSLayoutConstraint!
    @IBOutlet var cameraButtonBottomConstraint: NSLayoutConstraint!

    @IBOutlet var chatIconView: UIView!
    @IBOutlet var chatIconWhiteView: UIImageView!
    @IBOutlet var chatIconGrayView: UIImageView!
    @IBOutlet var chatIconWidthConstraint: NSLayoutConstraint!
    @IBOutlet var chatIconBottomConstraint: NSLayoutConstraint!
    @IBOutlet var chatIconHorizontalConstraint: NSLayoutConstraint!
    @IBOutlet var chatIconTextHorizontalConstraint: NSLayoutConstraint!
    @IBOutlet var chatIconTextBottomConstraint: NSLayoutConstraint!

    @IBOutlet var storiesIconView: UIView!
    @IBOutlet var storiesIconWhiteView: UIImageView!
    @IBOutlet var storiesIconGrayView: UIImageView!
    @IBOutlet var storiesIconHorizontalConstraint: NSLayoutConstraint!
    @IBOutlet var storiesIconTextHorizontalConstraint: NSLayoutConstraint!
    
    @IBOutlet var indicator: UIView!

    @IBOutlet var rearNavigationView: UIView!
    @IBOutlet var chatIconText: UILabel!
    @IBOutlet var storiesIconText: UILabel!

    @IBOutlet var colorView: UIView!
    
    // MARK: - Properties
    lazy var cameraButtonWidthConstraintConstant: CGFloat = {
      return self.cameraButtonWidthConstraint.constant
    }()
    lazy var cameraButtonBottomConstraintConstant: CGFloat = {
      return self.cameraButtonBottomConstraint.constant
    }()
    lazy var chatIconWidthConstraintConstant: CGFloat = {
      return self.chatIconWidthConstraint.constant
    }()
    lazy var chatIconBottomConstraintConstant: CGFloat = {
      return self.chatIconBottomConstraint.constant
    }()
    lazy var chatIconHorizontalConstraintConstant: CGFloat = {
      return self.chatIconHorizontalConstraint.constant
    }()
    lazy var storiesIconHorizontalConstraintConstant: CGFloat = {
      return self.storiesIconHorizontalConstraint.constant
    }()
    lazy var indicatorTransform: CGAffineTransform = {
      return self.cameraButtonView.transform
    }()
    
    // MARK: - View Life Cycle
    override func layoutSubviews() {
        super.layoutSubviews()
        indicator.layer.cornerRadius = indicator.bounds.height / 2
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setup()
    }
    
    override func prepareForInterfaceBuilder() {
        super.prepareForInterfaceBuilder()
        setup()
    }
    
    // ❤️ let touches through
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        let view = super.hitTest(point, with: event)
        return view == self ? nil : view
    }

    // MARK: - Internal
    func shadow(layer: CALayer, color: UIColor) {
      layer.shadowColor = color.cgColor
      layer.masksToBounds = false
      layer.shadowOffset = .zero
      layer.shadowOpacity = 1.0
      layer.shadowRadius = 0.5
    }

    func setup() {
      shadow(layer: cameraButtonWhiteView.layer, color: .black)
      shadow(layer: chatIconWhiteView.layer, color: .darkGray)
      shadow(layer: storiesIconWhiteView.layer, color: .darkGray)
    }
}
