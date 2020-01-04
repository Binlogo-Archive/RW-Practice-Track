//
//  ViewController.swift
//  Tinder
//
//  Created by Dylan Wang on 2020/1/3.
//  Copyright © 2020 WangXingbin. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    @IBOutlet weak var sizingView: UIView!
    
    let cardStack = CardStack()

    override func viewDidLoad() {
        super.viewDidLoad()
        
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        cardStack.addToSuperview(view)
        cardStack.delegate = self
    }

}

extension ViewController: CardStackDelegate {
    func cardStack(_ cardStack: CardStack, setViewForIndex index: Int) -> UIView? {
        guard let views = Bundle.main.loadNibNamed("DogView", owner: nil),
            let dogView = views.first as? DogView else { return nil }
        dogView.frame = sizingView.frame
        dogView.imageView.image = dogs[index].image
        dogView.nameLabel.text = dogs[index].description
        
        return dogView
    }
    
    func numberOfItems(in cardStack: CardStack) -> Int {
        dogs.count
    }
}

