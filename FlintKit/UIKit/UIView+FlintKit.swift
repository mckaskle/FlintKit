//
//  MIT License
//
//  UIView+FlintKit.swift
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

import Foundation
import UIKit


public extension UIView {
  
  // MARK: - Properties
  
  @IBInspectable
  var borderWidth: CGFloat {
    get { return layer.borderWidth }
    set { layer.borderWidth = newValue }
  }
  
  @IBInspectable
  var borderColor: UIColor? {
    get {
      guard let color = layer.borderColor else { return nil }
      return UIColor(cgColor: color)
    }
    set { layer.borderColor = newValue?.cgColor }
  }
  
  @IBInspectable
  var cornerRadius: CGFloat {
    get { return layer.cornerRadius }
    set {
      layer.cornerRadius = newValue
      
      if newValue > 0 {
        layer.masksToBounds = true
      }
    }
  }
  
  var safeAreaBounds: CGRect { return bounds.inset(by: safeAreaInsets) }
  var safeAreaFrame: CGRect { return frame.inset(by: safeAreaInsets) }
  
  
  // MARK: - Methods
  
  @available(iOS 9.0, *)
  func makeInsetConstraints(for other: UIView,
                            insetBy insets: UIEdgeInsets = .zero,
                            edges: UIRectEdge = .all) -> [NSLayoutConstraint] {
    var constraints: [NSLayoutConstraint] = []
    
    if edges.contains(.left) {
      constraints.append(other.leadingAnchor.constraint(equalTo: leadingAnchor, constant: insets.left))
    }
    
    if edges.contains(.top) {
      constraints.append(other.topAnchor.constraint(equalTo: topAnchor, constant: insets.top))
    }
    
    if edges.contains(.right) {
      constraints.append(trailingAnchor.constraint(equalTo: other.trailingAnchor, constant: insets.right))
    }
    
    if edges.contains(.bottom) {
      constraints.append(bottomAnchor.constraint(equalTo: other.bottomAnchor, constant: insets.bottom))
    }
    
    return constraints
  }
  
  @available(iOS 11.0, tvOS 11.0, *)
  func makeSafeAreaInsetConstraints(for other: UIView,
                                    insetBy insets: UIEdgeInsets = .zero,
                                    edges: UIRectEdge = .all) -> [NSLayoutConstraint] {
    var constraints: [NSLayoutConstraint] = []
    
    if edges.contains(.left) {
      constraints.append(other.leadingAnchor.constraint(equalTo: safeAreaLayoutGuide.leadingAnchor, constant: insets.left))
    }
    
    if edges.contains(.top) {
      constraints.append(other.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor, constant: insets.top))
    }
    
    if edges.contains(.right) {
      constraints.append(safeAreaLayoutGuide.trailingAnchor.constraint(equalTo: other.trailingAnchor, constant: insets.right))
    }
    
    if edges.contains(.bottom) {
      constraints.append(safeAreaLayoutGuide.bottomAnchor.constraint(equalTo: other.bottomAnchor, constant: insets.bottom))
    }
    
    return constraints
  }
  
}
