//
//  StoriesViewController.swift
//  SnapChat
//
//  Created by Dylan Wang on 2020/1/4.
//  Copyright © 2020 WangXingbin. All rights reserved.
//

import UIKit

class StoriesViewController: UIViewController, ColoredView {

    // MARK: - IBOutlets
    @IBOutlet var backgroundView: UIView!

    // MARK: - Properties
    var controllerColor: UIColor = UIColor(red: 0.59, green: 0.23, blue: 0.96, alpha: 1.0)

    // MARK: - View Life Cycle
    override func viewDidLoad() {
      super.viewDidLoad()

      backgroundView.layer.cornerRadius = 20
      backgroundView.layer.masksToBounds = true
    }

}
