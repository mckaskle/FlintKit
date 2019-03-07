//
//  MIT License
//
//  AccessibleStackView.swift
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


/// This UIStackView subclass is intended to be used to show a 2 column layout when UIContentSizeCategory is not an
/// accessibility category. When it is an accessibility category, it is assumed that the content is taking up enough
/// space that the stack view should be a 2 row layout instead of a 2 column layout.
public class AccessibleStackView: UIStackView {
  
  // MARK: - Object Lifecycle
  
  public override init(frame: CGRect) {
    #error("change this to be an extension")
    super.init(frame: frame)
    configureView()
  }
  
  public required init(coder: NSCoder) {
    super.init(coder: coder)
    configureView()
  }
  
  private func configureView() {
    refreshAxis()
  }
  
  
  // MARK: - Private Methods
  
  private func refreshAxis() {
    axis = traitCollection.preferredContentSizeCategory.isAccessibilityCategory_backwardsCompatible
      ? .vertical : .horizontal
  }
  
  
  // MARK: - UITraitEnvironment
  
  public override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
    super.traitCollectionDidChange(previousTraitCollection)
    
    refreshAxis()
  }
  
}
