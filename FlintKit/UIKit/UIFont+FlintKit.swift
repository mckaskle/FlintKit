//
//  UIFont+FlintKit.swift
//  FlintKit
//
//  Created by Devin McKaskle on 3/5/19.
//  Copyright © 2019 Devin McKaskle. All rights reserved.
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
