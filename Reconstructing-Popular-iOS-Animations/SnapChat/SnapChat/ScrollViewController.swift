//
//  ScrollViewController.swift
//  SnapChat
//
//  Created by Dylan Wang on 2020/1/4.
//  Copyright © 2020 WangXingbin. All rights reserved.
//

import UIKit

protocol ScrollViewControllerDelegate {
    func viewControllers() -> [UIViewController]
    func initialViewController() -> UIViewController
    func scrollViewDidScroll()
}

class ScrollViewController: UIViewController {
    
    // MARK: - Properties
    var delegate: ScrollViewControllerDelegate?

    var scrollView: UIScrollView {
      return view as! UIScrollView
    }

    var pageSize = CGSize.zero

    var viewControllers: [UIViewController]!
    var initialViewControllerIndex: Int = 0

    var isTransitioning = false
    
    // MARK: - View Life Cycle
    override func loadView() {
      let scrollView = UIScrollView()
      scrollView.bounces = false
      scrollView.showsHorizontalScrollIndicator = false
      scrollView.delegate = self
      scrollView.isPagingEnabled = true

      view = scrollView
      view.backgroundColor = .clear
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        pageSize = scrollView.bounds.size
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        viewControllers = delegate?.viewControllers()
        
        viewControllers.enumerated().forEach { (index, controller) in
            addChild(controller)
            controller.view.frame = frame(for: index)
            scrollView.addSubview(controller.view)
            controller.didMove(toParent: self)
        }
        
        scrollView.frame = CGRect(x: 0, y: 0, width: pageSize.width, height: pageSize.height)
        scrollView.contentSize = CGSize(width: pageSize.width * CGFloat(viewControllers.count),
                                        height: pageSize.height)
        
        if let controller = delegate?.initialViewController() {
            setController(to: controller, animated: false)
        }
    }

}

// MARK: - Public methods
extension ScrollViewController {
    
    func setController(to controller: UIViewController, animated: Bool) {
        guard let index = indexFor(controller: controller) else {
            return
        }
        let contentOffset = CGPoint(x: pageSize.width * CGFloat(index), y: 0)
        if animated {
            UIView.animate(withDuration: 0.2,
                           delay: 0,
                           options: [.curveEaseOut],
                           animations: {
                            self.scrollView.setContentOffset(contentOffset,
                                                             animated: false)
            })
        } else {
            scrollView.setContentOffset(contentOffset,
                                        animated: animated)
        }
    }
    
    func isControllerVisible(_ controller: UIViewController?) -> Bool {
        guard controller != nil else { return false }
        for i in 0..<viewControllers.count {
            if viewControllers[i] == controller {
                let controllerFrame = frame(for: i)
                return controllerFrame.intersects(scrollView.bounds)
            }
        }
        return false
    }
}

// MARK: - Private methods
private extension ScrollViewController {
    
    func frame(for index: Int) -> CGRect {
        return CGRect(x: CGFloat(index) * pageSize.width,
                      y: 0,
                      width: pageSize.width,
                      height: pageSize.height)
    }
    
    func indexFor(controller: UIViewController?) -> Int? {
        return viewControllers.firstIndex(where: { $0 == controller } )
    }
    
}

// MARK: - Scroll View Delegate
extension ScrollViewController: UIScrollViewDelegate {

  func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
    isTransitioning = true
  }

  func scrollViewDidScroll(_ scrollView: UIScrollView) {
    delegate?.scrollViewDidScroll()
  }

  func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
    isTransitioning = false
  }
}
