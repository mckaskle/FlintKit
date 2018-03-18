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


final public class ListTableViewCell: UITableViewCell {
  
  // MARK: - Object Lifecycle
  
  override public func awakeFromNib() {
    super.awakeFromNib()
    
    if #available(iOS 10.0, *) {
      headlineLabel.adjustsFontForContentSizeCategory = true
      subheadLabel.adjustsFontForContentSizeCategory = true
    }
    
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
  
  static public let rowHeight = UITableViewAutomaticDimension
  static public let estimatedRowHeight: CGFloat = 63
  
  public var headline: String? {
    get { return headlineLabel.text }
    set { headlineLabel.text = newValue }
  }
  
  public var subhead: String? {
    get { return subheadLabel.text }
    set { subheadLabel.text = newValue }
  }
  
  public var headlineFont: UIFont {
    get { return headlineLabel.font }
    set { headlineLabel.font = newValue }
  }
  
  public var subheadFont: UIFont {
    get { return subheadLabel.font }
    set { subheadLabel.font = newValue }
  }
  
  public var headlineColor: UIColor {
    get { return headlineLabel.textColor }
    set { headlineLabel.textColor = newValue }
  }
  
  public var subheadColor: UIColor {
    get { return subheadLabel.textColor }
    set { subheadLabel.textColor = newValue }
  }
  
  public var headlineTextAlignment: NSTextAlignment {
    get { return headlineLabel.textAlignment }
    set { headlineLabel.textAlignment = newValue }
  }
  
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
  
  public var labelsVerticalPadding: CGFloat {
    get { return labelsVerticalPaddingGuardConstraint.constant }
    set {
      labelsVerticalPaddingGuardConstraint.constant = newValue
      labelsVerticalPaddingSuggestionConstraint.constant = newValue
    }
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
  
  public var leadingAccessoryViewVerticalPadding: CGFloat {
    get { return leadingAccessoryViewVerticalPaddingGuardConstraint.constant }
    set {
      leadingAccessoryViewVerticalPaddingGuardConstraint.constant = newValue
      leadingAccessoryViewVerticalPaddingSuggestionConstraint.constant = newValue
    }
  }
  
  public var trailingAccessoryViewVerticalPadding: CGFloat {
    get { return trailingAccessoryViewVerticalPaddingGuardConstraint.constant }
    set {
      trailingAccessoryViewVerticalPaddingGuardConstraint.constant = newValue
      trailingAccessoryViewVerticalPaddingSuggestionConstraint.constant = newValue
    }
  }
  
  
  // MARK: - Private Properties
  
  private var defaultLabelsVerticalPadding: CGFloat = 15 // will be overridden in awakeFromNib
  private var defaultLeadingAccessoryViewHorizontalLabelPadding: CGFloat = 15 // will be overridden in awakeFromNib
  private var defaultTrailingAccessoryViewHorizontalLabelPadding: CGFloat = 15 // will be overridden in awakeFromNib
  private var defaultLeadingAccessoryViewHorizontalCellPadding: CGFloat = 15 // will be overridden in awakeFromNib
  private var defaultTrailingAccessoryViewHorizontalCellPadding: CGFloat = 15 // will be overridden in awakeFromNib
  private var defaultLeadingAccessoryViewVerticalPadding: CGFloat = 12 // will be overridden in awakeFromNib
  private var defaultTrailingAccessoryViewVerticalPadding: CGFloat = 12 // will be overridden in awakeFromNib
  
  @IBOutlet private weak var headlineLabel: UILabel!
  @IBOutlet private weak var subheadLabel: UILabel!
  @IBOutlet private weak var leadingAccessoryViewContainer: ListCellAccessoryContainerView!
  @IBOutlet private weak var trailingAccessoryViewContainer: ListCellAccessoryContainerView!
  
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
    leadingAccessoryView = nil
    headline = nil
    subhead = nil
    trailingAccessoryView = nil
    
    headlineFont = .preferredFont(forTextStyle: .body)
    subheadFont = .preferredFont(forTextStyle: .body)
    headlineColor = .darkText
    subheadColor = .darkText
    headlineTextAlignment = .natural
    subheadTextAlignment = .natural
    
    labelsVerticalPadding = defaultLabelsVerticalPadding
    leadingAccessoryViewHorizontalLabelPadding = defaultLeadingAccessoryViewHorizontalLabelPadding
    trailingAccessoryViewHorizontalLabelPadding = defaultTrailingAccessoryViewHorizontalLabelPadding
    leadingAccessoryViewHorizontalCellPadding = defaultLeadingAccessoryViewHorizontalCellPadding
    trailingAccessoryViewHorizontalCellPadding = defaultTrailingAccessoryViewHorizontalCellPadding
    leadingAccessoryViewVerticalPadding = defaultLeadingAccessoryViewVerticalPadding
    trailingAccessoryViewVerticalPadding = defaultTrailingAccessoryViewVerticalPadding
  }
  
  
  // MARK: - UITableViewCell
  
  override public func prepareForReuse() {
    super.prepareForReuse()
    
    reset()
  }
  
}


// MARK: - NibLoadableView
extension ListTableViewCell: NibLoadableView {}
