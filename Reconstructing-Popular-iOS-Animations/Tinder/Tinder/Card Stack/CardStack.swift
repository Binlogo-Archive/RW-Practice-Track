//
//  CardStack.swift
//  Tinder
//
//  Created by Dylan Wang on 2020/1/3.
//  Copyright © 2020 WangXingbin. All rights reserved.
//

import UIKit

protocol CardStackDelegate {
    func cardStack(_ cardStack: CardStack, setViewForIndex index: Int) -> UIView?
    func numberOfItems(in cardStack: CardStack) -> Int
}

class CardStack: NSObject {
    
    // MARK: - Constants
    enum Constants {
        static let initialScale: CGFloat = 0.95
    }
    
    // MARK: - Properties
    var delegate: CardStackDelegate? {
        didSet {
            load()
        }
    }
    
    private var superview: UIView?
    private var index = 0
    private var numberOfItems = 0
    
    private var cardBehavior: CardBehavior?
    
    private var topView: UIView? {
        didSet {
            topView?.isUserInteractionEnabled = true
            if let topView = topView {
                cardBehavior = CardBehavior()
                cardBehavior?.view = topView
                cardBehavior?.delegate = self
            } else {
                cardBehavior = nil
            }
        }
    }
    
    private var bottomView: UIView? {
        didSet {
            bottomView?.isUserInteractionEnabled = false
            bottomView?.transform = CGAffineTransform(scaleX: Constants.initialScale,
                                                      y: Constants.initialScale)
        }
    }
}

extension CardStack {
    func load() {
        index = 0
        topView = nil
        bottomView = nil
        numberOfItems = 0
        
        guard let delegate = delegate else { return }
        numberOfItems = delegate.numberOfItems(in: self)
        
        if numberOfItems > 0 {
            if let view = delegate.cardStack(self, setViewForIndex: 0) {
                topView = view
                superview?.addSubview(view)
            }
        }
        
        if numberOfItems > 1 {
            if let view = delegate.cardStack(self, setViewForIndex: 1) {
                bottomView = view
                superview?.addSubview(view)
                if let topView = topView {
                    superview?.bringSubviewToFront(topView)
                }
            }
        }
    }
    
    func addToSuperview(_ superview: UIView) {
        self.superview = superview
    }
    
    func showNextCard() {
        topView?.removeFromSuperview()
        topView = bottomView
        
        guard bottomView != nil else { return }
        
        index += 1
        bottomView = nil
        bottomView?.removeFromSuperview()
        
        if index + 1 >= numberOfItems {
            return
        }
        
        let card = delegate?.cardStack(self, setViewForIndex: index + 1)
        bottomView = card
        if let bottomView = card {
            superview?.addSubview(bottomView)
            if let topView = topView {
                superview?.bringSubviewToFront(topView)
            }
        }
    }
}

// MARK: - CardBehaviorDelegate
extension CardStack: CardBehaviorDelegate {
    func cardBehavior(movedBy delta: CGPoint) {
        //
        
        let maxDistance = superview!.bounds.width / 4
        let distance = min(delta.length, maxDistance)
        let result = distance / maxDistance
        let scale = (1.0 - Constants.initialScale) * result
        
        bottomView?.transform = CGAffineTransform(scaleX: Constants.initialScale + scale,
                                                  y: Constants.initialScale + scale)
    }
    
    func cardBehaviorDidEnd() {
        showNextCard()
    }
    
    func cardBehaviorCancelled() {
        
    }
}

private extension CGPoint {
    var length: CGFloat {
        return sqrt((x * x) + (y * y))
    }
}


