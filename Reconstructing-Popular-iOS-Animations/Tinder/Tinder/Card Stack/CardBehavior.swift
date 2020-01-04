//
//  CardBehavior.swift
//  Tinder
//
//  Created by Dylan Wang on 2020/1/3.
//  Copyright © 2020 WangXingbin. All rights reserved.
//

import UIKit

protocol CardBehaviorDelegate: class {
    func cardBehavior(movedBy delta: CGPoint)
    func cardBehaviorDidEnd()
    func cardBehaviorCancelled()
}

class CardBehavior: NSObject {
    
    // MARK: - Constants
    enum Constants {
        static let snapDamping: CGFloat = 0.7
        static let rotationDamping: CGFloat = 0.2
        static let thresholdMove: CGFloat = 0.4
        static let thresholdVelocity: CGFloat = 1000.0
    }
    
    // MARK: - Properties
    weak var delegate: CardBehaviorDelegate?

    var originalCenter: CGPoint = .zero
    var originalTouch: CGPoint = .zero
    
    weak var view: UIView! {
        didSet {
            let pan = UIPanGestureRecognizer(target: self, action: #selector(handlePan))
            view.addGestureRecognizer(pan)
            view.isUserInteractionEnabled = true
            originalCenter = view.center
        }
    }
    
    lazy var dynamicAnimator: UIDynamicAnimator = {
        return UIDynamicAnimator(referenceView: view.superview!)
    }()
    
    @objc func handlePan(_ gesture: UIPanGestureRecognizer) {
        guard let view = gesture.view,
            let superview = view.superview else {
            return
        }
        
        let delta = gesture.translation(in: superview)
        
        // Normalize between 0 and 1
        // where the minimum is 0
        // and the maximum is the half width of the view

        // result = (x - min) / (max - min)
        let maxDistance = superview.bounds.width * 0.5
        let percentDragged = (delta.x - 0) / (maxDistance - 0)
        
        switch gesture.state {
        case .began:
            
            dynamicAnimator.removeAllBehaviors()
            originalTouch = gesture.location(in: view)
            
        case .changed:
            
            var rotationDamping = Constants.rotationDamping
            if originalTouch.y > view.bounds.midY {
                rotationDamping *= -1
            }
            // rotate
            let angle = rotationDamping * percentDragged
            view.transform = CGAffineTransform(rotationAngle: angle)
            // move
            view.center = CGPoint(x: originalCenter.x + delta.x,
                                  y: originalCenter.y + delta.y)
            delegate?.cardBehavior(movedBy: delta)
            
        case .ended:
            
            var velocity = gesture.velocity(in: superview)
            let velocityX = abs(velocity.x)
            
            // Has it crossed the threshold?
            if abs(percentDragged) > Constants.thresholdMove
                // Is the thrust velocity over the threshold?
                || velocityX > Constants.thresholdVelocity {
                
                // minimum velocity required
                velocity.x = max(velocityX, Constants.thresholdVelocity)
                if percentDragged < 0 {
                    velocity.x *= -1
                }
                
                // add push behavior
                view.isUserInteractionEnabled = false
                let behavior = UIDynamicItemBehavior(items: [view])
                behavior.addLinearVelocity(velocity, for: view)
                
                behavior.action = { [weak self] in
                    if let viewFrame = self?.view.frame,
                        let superviewBounds = self?.view.superview?.bounds,
                    !viewFrame.intersects(superviewBounds) {
                        self?.delegate?.cardBehaviorDidEnd()
                        self?.dynamicAnimator.removeAllBehaviors()
                    }
                }
                
                dynamicAnimator.addBehavior(behavior)
            } else {
                // return to original position
                let behavior = UISnapBehavior(item: view, snapTo: originalCenter)
                behavior.damping = Constants.snapDamping
                dynamicAnimator.addBehavior(behavior)
            }
            
        default:
            break
        }
    }
}
