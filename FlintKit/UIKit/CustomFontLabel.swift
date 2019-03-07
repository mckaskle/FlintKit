//
//  CustomFontLabel.swift
//  FlintKit
//
//  Created by Devin McKaskle on 3/5/19.
//  Copyright © 2019 Devin McKaskle. All rights reserved.
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
    NotificationCenter.default.addObserver(
      self,
      selector: #selector(contentSizeCategoryDidChange),
      name: UIContentSizeCategory.didChangeNotification,
      object: nil
    )
    refreshFont()
  }
  
  required init?(coder aDecoder: NSCoder) {
    // This needs a value before calling super.init, so use a placeholder value until self can be accessed.
    designedFont = UIFont.systemFont(ofSize: UIFont.systemFontSize)
    
    super.init(coder: aDecoder)
    
    // The real designedFont will be set and the observer will be added in `awakeFromNib`.
  }
  
  override public func awakeFromNib() {
    super.awakeFromNib()
    
    designedFont = font
    NotificationCenter.default.addObserver(
      self,
      selector: #selector(contentSizeCategoryDidChange),
      name: UIContentSizeCategory.didChangeNotification,
      object: nil
    )
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
  
  
  // MARK: - Private Properties
  
  /// Set to `true` when the font is being refreshed internally so that it is known that the designedFont isn't being
  /// changed.
  private var isRefreshingFont = false
  
  
  // MARK: - Actions
  
  @objc dynamic private func contentSizeCategoryDidChange() {
    guard adjustsFontForContentSizeCategory else { return }
    refreshFont()
  }
  
  
  // MARK: - Private Methods
  
  private func refreshFont() {
    font = font.scaledFont(
      designedPointSize: designedFont.pointSize,
      textStyle: textStyle,
      maximumPointSize: maximumFontPointSize,
      compatibleWith: traitCollection
    )
  }
  
}
