//
//  MIT License
//
//  StoryboardLoadable.swift
//
//  Copyright (c) 2018 Devin McKaskle
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

import Foundation
import UIKit


public extension UITableView {
  
  func set(tableHeaderView subview: UIView, withWidth width: CGFloat, insetBy insets: UIEdgeInsets = UIEdgeInsets()) {
    assert(subview.translatesAutoresizingMaskIntoConstraints == false, "tableHeaderView should be managed by autolayout")
    
    let container = UIView()
    container.translatesAutoresizingMaskIntoConstraints = false
    container.addSubview(subview)
    
    let insetConstraints: [NSLayoutConstraint]
    
    if #available(iOS 11.0, *) {
      insetConstraints = container.makeSafeAreaInsetConstraints(for: subview, insetBy: insets)
    } else {
      insetConstraints = container.makeInsetConstraints(for: subview, insetBy: insets)
    }
    
    NSLayoutConstraint.activate(insetConstraints)
    
    let widthConstraint = container.widthAnchor.constraint(equalToConstant: width)
    widthConstraint.isActive = true
    
    let height = container.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize).height
    
    widthConstraint.isActive = false
    
    container.frame = CGRect(x: 0, y: 0, width: width, height: height)
    container.translatesAutoresizingMaskIntoConstraints = true
    tableHeaderView = container
  }
  
}
