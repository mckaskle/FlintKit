//
//  MIT License
//
//  UIFont+FlintKit.swift
//
//  Copyright (c) 2019 Devin McKaskle
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


extension UIFont {
  
  // MARK: - Public Properties
  
  /// Will use UIFontMetrics when available. Otherwise, will use UIContentSizeCategory's estimatedPointSizeScale to
  /// scale the font.
  public func scaledFont(designedPointSize: CGFloat, textStyle: UIFont.TextStyle = .body, maximumPointSize: CGFloat = .greatestFiniteMagnitude, compatibleWith traitCollection: UITraitCollection? = nil) -> UIFont {
    if #available(iOS 11.0, *) {
      let metrics = UIFontMetrics(forTextStyle: textStyle)
      return metrics.scaledFont(for: self, maximumPointSize: maximumPointSize, compatibleWith: traitCollection)
    } else {
      let category = traitCollection?.preferredContentSizeCategory ?? UIApplication.shared.preferredContentSizeCategory
      let scaledPointSize = pointSize * category.estimatedPointSizeScale
      // Bound so that 0 < scaledPointSize <= maximumPointSize
      return withSize(max(0.1, min(maximumPointSize, scaledPointSize)))
    }
  }
  
}
