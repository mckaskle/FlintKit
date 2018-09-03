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
  
  // MARK: - Object Lifecycle
  
  /// Supported formats are: #abc, #abcf, #aabbcc, #aabbccff where:
  /// - a: red
  /// - b: blue
  /// - c: green
  /// - f: alpha
  public convenience init?(hexadecimal: String) {
    var normalized = hexadecimal
    if normalized.hasPrefix("#") {
      normalized = String(normalized.dropFirst())
    }
    
    var characterCount = normalized.count
    if characterCount == 3 || characterCount == 4 {
      // Double each character.
      normalized = normalized.lazy.map { "\($0)\($0)" }.joined()
      // Character count has doubled.
      characterCount *= 2
    }
    
    if characterCount == 6 {
      // If alpha was not included, add it.
      normalized.append("ff")
      characterCount += 2
    }
    
    // If the string is not 8 characters at this point, it could not be normalized.
    guard characterCount == 8 else { return nil }
    
    let scanner = Scanner(string: normalized)
    var value: UInt32 = 0
    guard scanner.scanHexInt32(&value) else { return nil }
    
    let red = CGFloat((value & 0xFF000000) >> 24) / 255
    let green = CGFloat((value & 0xFF0000) >> 16) / 255
    let blue = CGFloat((value & 0xFF00) >> 8) / 255
    let alpha = CGFloat(value & 0xFF) / 255
    self.init(red: red, green: green, blue: blue, alpha: alpha)
  }
  
  
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
