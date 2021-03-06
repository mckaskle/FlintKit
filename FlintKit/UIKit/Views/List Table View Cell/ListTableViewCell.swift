//
//  MIT License
//
//  ListTableViewCell.swift
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

import UIKit


@available(iOS 11.0, *)
private let verticalPaddingMetrics = UIFontMetrics(forTextStyle: .body)


final public class ListTableViewCell: UITableViewCell {
  
  // MARK: - Object Lifecycle
  
  override public func awakeFromNib() {
    super.awakeFromNib()
    
    defaultInterLabelsSpacing = interLabelsSpacingConstraint.constant
    defaultLabelsVerticalPadding = labelsVerticalPaddingGuardConstraint.constant
    defaultLeadingAccessoryViewHorizontalLabelPadding = leadingAccessoryViewHorizontalLabelPaddingConstraint.constant
    defaultTrailingAccessoryViewHorizontalLabelPadding = trailingAccessoryViewHorizontalLabelPaddingConstraint.constant
    defaultLeadingAccessoryViewHorizontalCellPadding = leadingAccessoryViewHorizontalCellPaddingConstraint.constant
    defaultTrailingAccessoryViewHorizontalCellPadding = trailingAccessoryViewHorizontalCellPaddingConstraint.constant
    defaultLeadingAccessoryViewVerticalPadding = leadingAccessoryViewVerticalPaddingGuardConstraint.constant
    defaultTrailingAccessoryViewVerticalPadding = trailingAccessoryViewVerticalPaddingGuardConstraint.constant
    
    reset()
  }
  
  
  // MARK: - Properties
  
  static public let rowHeight = UITableView.automaticDimension
  static public let estimatedRowHeight: CGFloat = 63
  
  public var headlineLabel: Label { return headlineLabelView }
  public var subheadLabel: Label { return subheadLabelView }
  
  @available(*, deprecated, renamed: "headlineLabel.text")
  public var headline: String? {
    get { return headlineLabel.text }
    set { headlineLabel.text = newValue }
  }
  
  @available(*, deprecated, renamed: "subheadLabel.text")
  public var subhead: String? {
    get { return subheadLabel.text }
    set { subheadLabel.text = newValue }
  }
  
  @available(*, deprecated, renamed: "headlineLabel.font")
  public var headlineFont: UIFont {
    get { return headlineLabel.font }
    set { headlineLabel.font = newValue }
  }
  
  @available(*, deprecated, renamed: "subheadLabel.font")
  public var subheadFont: UIFont {
    get { return subheadLabel.font }
    set { subheadLabel.font = newValue }
  }
  
  @available(*, deprecated, renamed: "headlineLabel.textColor")
  public var headlineColor: UIColor! {
    get { return headlineLabel.textColor }
    set { headlineLabel.textColor = newValue }
  }
  
  @available(*, deprecated, renamed: "subheadLabel.textColor")
  public var subheadColor: UIColor! {
    get { return subheadLabel.textColor }
    set { subheadLabel.textColor = newValue }
  }
  
  @available(*, deprecated, renamed: "headlineLabel.textAlignment")
  public var headlineTextAlignment: NSTextAlignment {
    get { return headlineLabel.textAlignment }
    set { headlineLabel.textAlignment = newValue }
  }
  
  @available(*, deprecated, renamed: "subheadLabel.textAlignment")
  public var subheadTextAlignment: NSTextAlignment {
    get { return subheadLabel.textAlignment }
    set { subheadLabel.textAlignment = newValue }
  }
  
  public var leadingAccessoryView: UIView? {
    get { return leadingAccessoryViewContainer.subview }
    set {
      leadingAccessoryViewContainer.subview = newValue
      leadingAccessoryViewHorizontalLabelPaddingConstraint.constant = newValue == nil ? 0 : leadingAccessoryViewHorizontalLabelPadding
    }
  }
  
  public var trailingAccessoryView: UIView? {
    get { return trailingAccessoryViewContainer.subview }
    set {
      trailingAccessoryViewContainer.subview = newValue
      trailingAccessoryViewHorizontalLabelPaddingConstraint.constant = newValue == nil ? 0 : trailingAccessoryViewHorizontalLabelPadding
    }
  }
  
  public var interLabelsSpacing: CGFloat = 0 {
    didSet { refreshInterLabelSpacing() }
  }
  
  public var labelsVerticalPadding: CGFloat = 0 {
    didSet { refreshLabelsVerticalPaddingConstraints() }
  }
  
  public var leadingAccessoryViewHorizontalLabelPadding: CGFloat = 0 {
    didSet {
      guard leadingAccessoryView != nil else { return }
      leadingAccessoryViewHorizontalLabelPaddingConstraint.constant = leadingAccessoryViewHorizontalLabelPadding
    }
  }
  
  public var trailingAccessoryViewHorizontalLabelPadding: CGFloat = 0 {
    didSet {
      guard trailingAccessoryView != nil else { return }
      trailingAccessoryViewHorizontalLabelPaddingConstraint.constant = trailingAccessoryViewHorizontalLabelPadding
    }
  }
  
  public var leadingAccessoryViewHorizontalCellPadding: CGFloat {
    get { return leadingAccessoryViewHorizontalCellPaddingConstraint.constant }
    set { leadingAccessoryViewHorizontalCellPaddingConstraint.constant = newValue }
  }
  
  public var trailingAccessoryViewHorizontalCellPadding: CGFloat {
    get { return trailingAccessoryViewHorizontalCellPaddingConstraint.constant }
    set { trailingAccessoryViewHorizontalCellPaddingConstraint.constant = newValue }
  }
  
  public var leadingAccessoryViewVerticalPadding: CGFloat = 0 {
    didSet { refreshLeadingAccessoryViewVerticalPaddingConstraints() }
  }
  
  public var trailingAccessoryViewVerticalPadding: CGFloat = 0 {
    didSet { refreshTrailingAccessoryViewVerticalPaddingConstraints() }
  }
  
  public var adjustsVerticalPaddingForContentSizeCategory = true {
    didSet {
      guard adjustsVerticalPaddingForContentSizeCategory != oldValue else { return }
      refreshAllVerticalPaddingConstraints()
    }
  }
  
  
  // MARK: - Private Properties
  
  private var defaultInterLabelsSpacing: CGFloat = 0 // will be overridden in awakeFromNib
  private var defaultLabelsVerticalPadding: CGFloat = 15 // will be overridden in awakeFromNib
  private var defaultLeadingAccessoryViewHorizontalLabelPadding: CGFloat = 15 // will be overridden in awakeFromNib
  private var defaultTrailingAccessoryViewHorizontalLabelPadding: CGFloat = 15 // will be overridden in awakeFromNib
  private var defaultLeadingAccessoryViewHorizontalCellPadding: CGFloat = 15 // will be overridden in awakeFromNib
  private var defaultTrailingAccessoryViewHorizontalCellPadding: CGFloat = 15 // will be overridden in awakeFromNib
  private var defaultLeadingAccessoryViewVerticalPadding: CGFloat = 12 // will be overridden in awakeFromNib
  private var defaultTrailingAccessoryViewVerticalPadding: CGFloat = 12 // will be overridden in awakeFromNib
  
  @IBOutlet private weak var headlineLabelView: UILabel!
  @IBOutlet private weak var subheadLabelView: UILabel!
  @IBOutlet private weak var leadingAccessoryViewContainer: ListCellAccessoryContainerView!
  @IBOutlet private weak var trailingAccessoryViewContainer: ListCellAccessoryContainerView!
  
  @IBOutlet private weak var interLabelsSpacingConstraint: NSLayoutConstraint!
  @IBOutlet private weak var labelsVerticalPaddingGuardConstraint: NSLayoutConstraint!
  @IBOutlet private weak var labelsVerticalPaddingSuggestionConstraint: NSLayoutConstraint!
  @IBOutlet private weak var leadingAccessoryViewHorizontalLabelPaddingConstraint: NSLayoutConstraint!
  @IBOutlet private weak var trailingAccessoryViewHorizontalLabelPaddingConstraint: NSLayoutConstraint!
  @IBOutlet private weak var leadingAccessoryViewHorizontalCellPaddingConstraint: NSLayoutConstraint!
  @IBOutlet private weak var trailingAccessoryViewHorizontalCellPaddingConstraint: NSLayoutConstraint!
  @IBOutlet private weak var leadingAccessoryViewVerticalPaddingGuardConstraint: NSLayoutConstraint!
  @IBOutlet private weak var leadingAccessoryViewVerticalPaddingSuggestionConstraint: NSLayoutConstraint!
  @IBOutlet private weak var trailingAccessoryViewVerticalPaddingGuardConstraint: NSLayoutConstraint!
  @IBOutlet private weak var trailingAccessoryViewVerticalPaddingSuggestionConstraint: NSLayoutConstraint!
  
  
  // MARK: - Private Methods
  
  private func reset() {
    accessoryType = .none
    indentationLevel = 0
    selectionStyle = .default
    
    leadingAccessoryView = nil
    headlineLabel.resetToDefaults()
    subheadLabel.resetToDefaults()
    trailingAccessoryView = nil
    
    interLabelsSpacing = defaultInterLabelsSpacing
    labelsVerticalPadding = defaultLabelsVerticalPadding
    leadingAccessoryViewHorizontalLabelPadding = defaultLeadingAccessoryViewHorizontalLabelPadding
    trailingAccessoryViewHorizontalLabelPadding = defaultTrailingAccessoryViewHorizontalLabelPadding
    leadingAccessoryViewHorizontalCellPadding = defaultLeadingAccessoryViewHorizontalCellPadding
    trailingAccessoryViewHorizontalCellPadding = defaultTrailingAccessoryViewHorizontalCellPadding
    leadingAccessoryViewVerticalPadding = defaultLeadingAccessoryViewVerticalPadding
    trailingAccessoryViewVerticalPadding = defaultTrailingAccessoryViewVerticalPadding
    
    accessibilityIdentifier = nil
  }
  
  private func scaledVerticalPadding(from: CGFloat) -> CGFloat {
    guard adjustsVerticalPaddingForContentSizeCategory else { return from }
    if #available(iOS 11.0, *) {
      return verticalPaddingMetrics.scaledValue(for: from, compatibleWith: traitCollection)
    } else {
      return from
    }
  }
  
  private func refreshInterLabelSpacing() {
    interLabelsSpacingConstraint.constant = scaledVerticalPadding(from: interLabelsSpacing)
  }
  
  private func refreshLabelsVerticalPaddingConstraints() {
    let padding = scaledVerticalPadding(from: labelsVerticalPadding)
    labelsVerticalPaddingGuardConstraint.constant = padding
    labelsVerticalPaddingSuggestionConstraint.constant = padding
  }
  
  private func refreshLeadingAccessoryViewVerticalPaddingConstraints() {
    let padding = scaledVerticalPadding(from: leadingAccessoryViewVerticalPadding)
    leadingAccessoryViewVerticalPaddingGuardConstraint.constant = padding
    leadingAccessoryViewVerticalPaddingSuggestionConstraint.constant = padding
  }
  
  private func refreshTrailingAccessoryViewVerticalPaddingConstraints() {
    let padding = scaledVerticalPadding(from: trailingAccessoryViewVerticalPadding)
    trailingAccessoryViewVerticalPaddingGuardConstraint.constant = padding
    trailingAccessoryViewVerticalPaddingSuggestionConstraint.constant = padding
  }
  
  private func refreshAllVerticalPaddingConstraints() {
    refreshInterLabelSpacing()
    refreshLabelsVerticalPaddingConstraints()
    refreshLeadingAccessoryViewVerticalPaddingConstraints()
    refreshTrailingAccessoryViewVerticalPaddingConstraints()
  }
  
  
  // MARK: - UITableViewCell
  
  override public func prepareForReuse() {
    super.prepareForReuse()
    
    reset()
  }
  
  
  // MARK: - UIAccessibilityIdentification
  
  override public var accessibilityIdentifier: String? {
    didSet {
      headlineLabel.accessibilityIdentifier = accessibilityIdentifier.map { "\($0).headline" }
      subheadLabel.accessibilityIdentifier = accessibilityIdentifier.map { "\($0).subhead" }
    }
  }
  
  
  // MARK: - UITraitEnvironment
  
  public override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
    super.traitCollectionDidChange(previousTraitCollection)
    
    if previousTraitCollection?.preferredContentSizeCategory != traitCollection.preferredContentSizeCategory && adjustsVerticalPaddingForContentSizeCategory {
      refreshAllVerticalPaddingConstraints()
    }
  }
  
}


// MARK: - NibLoadableView
extension ListTableViewCell: NibLoadableView {}
