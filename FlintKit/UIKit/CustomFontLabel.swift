//
//  MIT License
//
//  CustomFontLabel.swift
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


/// CustomFontLabel automatically scales the font size
/// based on the current content size category. This works
/// even if a font is set without using `.preferredFont` or
/// `UIFontMetrics`.
@IBDesignable
public final class CustomFontLabel: UILabel {
  
  // MARK: - Object Lifecycle
  
  public override init(frame: CGRect) {
    // This needs a value before calling super.init, so use a placeholder value until self can be accessed.
    designedFont = UIFont.systemFont(ofSize: UIFont.systemFontSize)
    
    super.init(frame: frame)
    
    designedFont = font
    refreshFont()
  }
  
  required init?(coder aDecoder: NSCoder) {
    // This needs a value before calling super.init, so use a placeholder value until self can be accessed.
    designedFont = UIFont.systemFont(ofSize: UIFont.systemFontSize)
    
    super.init(coder: aDecoder)
    
    // The real designedFont will be set in `awakeFromNib`.
  }
  
  override public func awakeFromNib() {
    super.awakeFromNib()
    designedFont = font
  }
  
  
  // MARK: - Public Properties
  
  /// IB will give a warning if `adjustsFontForContentSizeCategory` is turned
  /// on for labels that are not using a Dynamic Type text style. This property
  /// is an alias for `adjustsFontForContentSizeCategory` that works around this
  /// issue.
  @IBInspectable
  public var autoAdjustFontSize: Bool {
    get { return adjustsFontForContentSizeCategory }
    set { adjustsFontForContentSizeCategory = newValue }
  }
  
  @IBInspectable
  public var maximumFontPointSize: CGFloat = .greatestFiniteMagnitude {
    didSet { refreshFont() }
  }
  
  @IBInspectable
  public var textStyle: UIFont.TextStyle = .body {
    didSet { refreshFont() }
  }
  
  /// The font as the label was designed (assuming it was in the default size category). This will be the base font that
  /// will scale up and down as the UIContentSizeCategory changes.
  ///
  /// This is the only supported way to change the font. `font` will be managed internally based on `designedFont`.
  ///
  /// Note: if the label was created in IB, the designedFont will be set to whatever the font is in awakeFromNib.
  public var designedFont: UIFont {
    didSet { refreshFont() }
  }
  
  
  // MARK: - Private Methods
  
  private func refreshFont() {
    font = designedFont.scaledFont(
      designedPointSize: designedFont.pointSize,
      textStyle: textStyle,
      maximumPointSize: maximumFontPointSize,
      compatibleWith: traitCollection
    )
  }
  
  
  // MARK: - UITraitEnvironment
  
  public override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
    super.traitCollectionDidChange(previousTraitCollection)
    
    guard adjustsFontForContentSizeCategory else { return }
    refreshFont()
  }
  
}
