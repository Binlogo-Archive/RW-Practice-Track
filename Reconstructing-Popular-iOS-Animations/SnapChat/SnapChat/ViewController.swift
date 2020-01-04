//
//  ViewController.swift
//  SnapChat
//
//  Created by Dylan Wang on 2020/1/4.
//  Copyright © 2020 WangXingbin. All rights reserved.
//

import UIKit

protocol ColoredView {
    var controllerColor: UIColor { get set }
}

class ViewController: UIViewController {
    
    // MARK: - Properties
    var scrollViewController: ScrollViewController!
    
    lazy var chatViewController: UIViewController! = {
      return self.storyboard?.instantiateViewController(withIdentifier: "ChatViewController")
    }()

    lazy var storiesViewController: UIViewController! = {
      return self.storyboard?.instantiateViewController(withIdentifier: "StoriesViewController")
    }()

    lazy var lensViewController: UIViewController! = {
      return self.storyboard?.instantiateViewController(withIdentifier: "LensViewController")
    }()

    var cameraViewController: CameraViewController!
    
    // MARK: - IBOutlets
    @IBOutlet var navigationView: NavigationView!

    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let controller = segue.destination as? CameraViewController {
            cameraViewController = controller
        } else if let controller = segue.destination as? ScrollViewController {
            scrollViewController = controller
            scrollViewController.delegate = self
        }
    }
}

// MARK: - IBActions
extension ViewController {
    
    @IBAction func handleChatIconTap(_ sender: UITapGestureRecognizer) {
        scrollViewController.setController(to: chatViewController, animated: true)
    }
    
    @IBAction func handleStoriesIconTap(_ sender: UITapGestureRecognizer) {
        scrollViewController.setController(to: storiesViewController, animated: true)
    }
    
    @IBAction func handleCameraButton(_ sender: UITapGestureRecognizer) {
        if !scrollViewController.isTransitioning &&
            scrollViewController.isControllerVisible(lensViewController) {
            print("Happy Snap!!!")
        } else {
            scrollViewController.setController(to: lensViewController, animated: true)
        }
    }
}

// MARK: - ScrollViewControllerDelegate
extension ViewController: ScrollViewControllerDelegate {
    func viewControllers() -> [UIViewController] {
        return [chatViewController, lensViewController, storiesViewController]
    }
    
    func initialViewController() -> UIViewController {
        return lensViewController
    }
    
    func scrollViewDidScroll() {
        // result = (x - min) / (max - min)
        
        // caculate percentage for animation
        let min: CGFloat = 0
        let max: CGFloat = scrollViewController.pageSize.width
        let x = scrollViewController.scrollView.contentOffset.x
        let result = ((x - min) / (max - min)) - 1
        
        var controller: UIViewController?
        if scrollViewController.isControllerVisible(chatViewController) {
            controller = chatViewController
        } else if scrollViewController.isControllerVisible(storiesViewController) {
            controller = storiesViewController
        }
        
        navigationView.animate(to: controller, percent: result)
    }
}
