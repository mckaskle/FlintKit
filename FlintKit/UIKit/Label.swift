//
//  MIT License
//
//  Label.swift
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

import UIKit


/// Provides a way to expose a label publicly for customization without exposing methods that generally shouldn't be
/// public, such as removeFromSuperview().
public protocol Label: class {
  
  // MARK: - Accessing the Text Attributes
  
  var text: String? { get set }
  var attributedText: NSAttributedString? { get set }
  var font: UIFont! { get set }
  var textColor: UIColor! { get set }
  var textAlignment: NSTextAlignment { get set }
  var lineBreakMode: NSLineBreakMode { get set }
  var isEnabled: Bool { get set }
  
  
  // MARK: - Sizing the Label's Text
  
  var adjustsFontSizeToFitWidth: Bool { get set }
  var allowsDefaultTighteningForTruncation: Bool { get set }
  var baselineAdjustment: UIBaselineAdjustment { get set }
  var minimumScaleFactor: CGFloat { get set }
  var numberOfLines: Int { get set }
  
  
  // MARK: - Drawing a Shadow
  
  var shadowColor: UIColor? { get set }
  var shadowOffset: CGSize { get set }
  
  
  // MARK: - Getting the Layout Constraints
  
  var preferredMaxLayoutWidth: CGFloat { get set }
  
  
  // MARK: - Setting and Getting Attributes
  
  var isUserInteractionEnabled: Bool { get set }
  
  
  // MARK: - UIAccessibilityIdentification
  
  var accessibilityIdentifier: String? { get set }
  
  
  // MARK: - UIContentSizeCategoryAdjusting
  
  @available(iOS 10.0, *)
  var adjustsFontForContentSizeCategory: Bool { get set }
  
}


public extension Label {
  
  func resetToDefaults() {
    text = nil
    font = .preferredFont(forTextStyle: .body)
    textColor = .darkText
    textAlignment = .natural
    lineBreakMode = .byTruncatingTail
    isEnabled = true
    
    adjustsFontSizeToFitWidth = false
    allowsDefaultTighteningForTruncation = false
    baselineAdjustment = .alignBaselines
    minimumScaleFactor = 0
    numberOfLines = 0
    
    shadowColor = nil
    shadowOffset = CGSize(width: 0, height: -1)
    
    isUserInteractionEnabled = false
    
    accessibilityIdentifier = nil
    
    adjustsFontForContentSizeCategory = true
  }
  
}


extension UILabel: Label {}
