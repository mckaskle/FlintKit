//
//  MIT License
//
//  UIViewController+FlintKit.swift
//
//  Copyright (c) 2016 Devin McKaskle
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
//

import UIKit


public extension UIViewController {
  
  func add(child: UIViewController, in superview: UIView, withFrame frame: CGRect) {
    addChildViewController(child)
    child.view.frame = frame
    superview.addSubview(child.view)
    child.didMove(toParentViewController: self)
  }
  
  func remove(child: UIViewController) {
    child.willMove(toParentViewController: nil)
    child.view.removeFromSuperview()
    child.removeFromParentViewController()
  }
  
  /// UIKit will not present a view controller if the presenter is already 
  /// presenting another view controller. This method works around that behavior
  /// by presenting on top of whatever view controllers are already presented.
  ///
  /// **Warning:** If the view controller that will be doing the presenting is
  /// in the process of being presented or dismissed, a short delay will be
  /// introduced before retrying.
  func presentOnPresented(_ viewControllerToPresent: UIViewController, animated: Bool, completion: (() -> Void)?) {
    var presenter = self
    while true {
      guard let presented = presenter.presentedViewController else { break }
      presenter = presented
    }
    
    guard !presenter.isBeingDismissed, !presenter.isBeingPresented else {
      DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(350)) { [weak self] in
        self?.presentOnPresented(viewControllerToPresent, animated: animated, completion: completion)
      }
      return
    }
    
    presenter.present(viewControllerToPresent, animated: animated, completion: completion)
  }
  
}
