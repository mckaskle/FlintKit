//
//  MIT License
//
//  UIContentSizeCategory+FlintKit.swift
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


extension UIContentSizeCategory {
  
  // MARK: - Public Properties
  
  public var estimatedPointSizeScale: CGFloat {
    // Based on how the Body style's point size scales here:
    // https://developer.apple.com/ios/human-interface-guidelines/visual-design/typography/
    switch self {
    case UIContentSizeCategory.extraSmall: return 14/17
    case UIContentSizeCategory.small: return 15/17
    case UIContentSizeCategory.medium: return 16/17
    case UIContentSizeCategory.large: return 1
    case UIContentSizeCategory.extraLarge: return 19/17
    case UIContentSizeCategory.extraExtraLarge: return 21/17
    case UIContentSizeCategory.extraExtraExtraLarge: return 23/17
    case UIContentSizeCategory.accessibilityMedium: return 28/17
    case UIContentSizeCategory.accessibilityLarge: return 33/17
    case UIContentSizeCategory.accessibilityExtraLarge: return 40/17
    case UIContentSizeCategory.accessibilityExtraExtraLarge: return 47/17
    case UIContentSizeCategory.accessibilityExtraExtraExtraLarge: return 53/17
    default: return 1
    }
  }
  
  /// This makes the convenience function `isAccessibilityCategory` available to pre-iOS 11 systems.
  public var isAccessibilityCategory_backwardsCompatible: Bool {
    if #available(iOS 11.0, *) {
      return isAccessibilityCategory
    } else {
      let accessibilityCategories: Set<UIContentSizeCategory> = [
        .accessibilityMedium,
        .accessibilityLarge,
        .accessibilityExtraLarge,
        .accessibilityExtraExtraLarge,
        .accessibilityExtraExtraExtraLarge
      ]
      
      return accessibilityCategories.contains(self)
    }
  }
  
}
