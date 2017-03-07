//
//  MIT License
//
//  UIViewController+FlintKit.swift
//
//  Copyright (c) 2017 Devin McKaskle
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


public extension UINavigationController {
  
  /// This method lets you pop the navigation stack to the given view controller.
  /// It works even if instead of being a directly managed view controller in the
  /// stack, it's a child of a view controller that is managed by the navigation 
  /// stack.
  @discardableResult func popToParentOfChildViewController(_ child: UIViewController, animated: Bool) -> [UIViewController]? {
    // Find the view controller that is both in the navigation controller's managed view
    // controllers and in the child's hierarchy.
    var childHeirarchy: Set<UIViewController> = [child]
    var nextParent: UIViewController? = child.parent
    while true {
      guard let parent = nextParent else { break }
      childHeirarchy.insert(parent)
      nextParent = parent.parent
    }
    
    let managed: Set<UIViewController> = Set(viewControllers)
    let intersection = managed.intersection(childHeirarchy)
    guard let target = intersection.first else { return nil }
    return popToViewController(target, animated: animated)
  }
  
}
