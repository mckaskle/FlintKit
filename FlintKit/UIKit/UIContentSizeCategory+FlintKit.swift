//
//  UIContentSizeCategory+FlintKit.swift
//  FlintKit
//
//  Created by Devin McKaskle on 3/5/19.
//  Copyright © 2019 Devin McKaskle. All rights reserved.
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
  
}
