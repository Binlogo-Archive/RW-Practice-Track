//
//  DogView.swift
//  Tinder
//
//  Created by Dylan Wang on 2020/1/4.
//  Copyright © 2020 WangXingbin. All rights reserved.
//

import UIKit

class DogView: UIView {

    // MARK: - IBOutlets
    @IBOutlet var imageView: UIImageView!
    @IBOutlet var nameLabel: UILabel!
    @IBOutlet var likeView: UIImageView!

    @IBInspectable var cornerRadius: CGFloat = 10 {
      didSet {
        layer.cornerRadius = cornerRadius
      }
    }

}

extension DogView {
    func animate(percent: CGFloat) {
        
    }
}
