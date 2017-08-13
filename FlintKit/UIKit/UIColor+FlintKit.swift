//
//  MIT License
//
//  UIColor+FlintKit.swift
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

import Foundation
import UIKit


fileprivate enum UIColorError: Error {
  case couldNotGenerateImage
}


extension UIColor {
  
  // MARK: - Public Methods
  
  public func image(withSize size: CGSize) throws -> UIImage {
    var alpha: CGFloat = 1
    if !getRed(nil, green: nil, blue: nil, alpha: &alpha) {
      alpha = 1
    }
    
    UIGraphicsBeginImageContextWithOptions(size, alpha == 1, 0)
    defer { UIGraphicsEndImageContext() }
    
    let context = UIGraphicsGetCurrentContext()
    context?.setFillColor(cgColor)
    context?.fill(CGRect(origin: .zero, size: size))
    
    guard let image = UIGraphicsGetImageFromCurrentImageContext() else {
      throw UIColorError.couldNotGenerateImage
    }
    
    return image
  }
  
}
