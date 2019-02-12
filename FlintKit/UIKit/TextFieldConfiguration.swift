//
//  MIT License
//
//  TextFieldConfiguration.swift
//
//  Copyright (c) 2018 Devin McKaskle
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
public struct TextFieldConfiguration {
  
  // MARK: - Object Lifecycle
  
  public init(placeholder: String = "",
              textContentType: UITextContentType? = nil,
              autocapitalizationType: UITextAutocapitalizationType = .none,
              autocorrectionType: UITextAutocorrectionType = .default,
              smartDashesType: UITextSmartDashesType = .default,
              smartInsertDeleteType: UITextSmartInsertDeleteType = .default,
              smartQuotesType: UITextSmartQuotesType = .default,
              spellCheckingType: UITextSpellCheckingType = .default,
              keyboardType: UIKeyboardType = .default,
              keyboardAppearance: UIKeyboardAppearance = .default,
              returnKeyType: UIReturnKeyType = .default,
              enablesReturnKeyAutomatically: Bool = false,
              isSecureTextEntry: Bool = false) {
    self.placeholder = placeholder
    self.textContentType = textContentType
    self.autocapitalizationType = autocapitalizationType
    self.autocorrectionType = autocorrectionType
    self.smartDashesType = smartDashesType
    self.smartInsertDeleteType = smartInsertDeleteType
    self.smartQuotesType = smartQuotesType
    self.spellCheckingType = spellCheckingType
    self.keyboardType = keyboardType
    self.keyboardAppearance = keyboardAppearance
    self.returnKeyType = returnKeyType
    self.enablesReturnKeyAutomatically = enablesReturnKeyAutomatically
    self.isSecureTextEntry = isSecureTextEntry
  }
  
  
  // MARK: - Public Properties
  
  public var placeholder: String
  public var textContentType: UITextContentType?
  public var autocapitalizationType: UITextAutocapitalizationType
  public var autocorrectionType: UITextAutocorrectionType
  public var smartDashesType: UITextSmartDashesType
  public var smartInsertDeleteType: UITextSmartInsertDeleteType
  public var smartQuotesType: UITextSmartQuotesType
  public var spellCheckingType: UITextSpellCheckingType
  public var keyboardType: UIKeyboardType
  public var keyboardAppearance: UIKeyboardAppearance
  public var returnKeyType: UIReturnKeyType
  public var enablesReturnKeyAutomatically: Bool
  public var isSecureTextEntry: Bool
  
}


public extension UITextField {
  
  @available(iOS 11.0, *)
  var configuration: TextFieldConfiguration {
    get {
      return TextFieldConfiguration(
        placeholder: placeholder ?? "",
        textContentType: textContentType,
        autocapitalizationType: autocapitalizationType,
        autocorrectionType: autocorrectionType,
        smartDashesType: smartDashesType,
        smartInsertDeleteType: smartInsertDeleteType,
        smartQuotesType: smartQuotesType,
        spellCheckingType: spellCheckingType,
        keyboardType: keyboardType,
        keyboardAppearance: keyboardAppearance,
        returnKeyType: returnKeyType,
        enablesReturnKeyAutomatically: enablesReturnKeyAutomatically,
        isSecureTextEntry: isSecureTextEntry
      )
    }
    
    set {
      placeholder = newValue.placeholder
      textContentType = newValue.textContentType
      autocapitalizationType = newValue.autocapitalizationType
      autocorrectionType = newValue.autocorrectionType
      smartDashesType = newValue.smartDashesType
      smartInsertDeleteType = newValue.smartInsertDeleteType
      smartQuotesType = newValue.smartQuotesType
      spellCheckingType = newValue.spellCheckingType
      keyboardType = newValue.keyboardType
      keyboardAppearance = newValue.keyboardAppearance
      returnKeyType = newValue.returnKeyType
      enablesReturnKeyAutomatically = newValue.enablesReturnKeyAutomatically
      isSecureTextEntry = newValue.isSecureTextEntry
    }
  }
  
}


public extension UITextView {
  
  @available(iOS 11.0, *)
  var configuration: TextFieldConfiguration {
    get {
      return TextFieldConfiguration(
        textContentType: textContentType,
        autocapitalizationType: autocapitalizationType,
        autocorrectionType: autocorrectionType,
        smartDashesType: smartDashesType,
        smartInsertDeleteType: smartInsertDeleteType,
        smartQuotesType: smartQuotesType,
        spellCheckingType: spellCheckingType,
        keyboardType: keyboardType,
        keyboardAppearance: keyboardAppearance,
        returnKeyType: returnKeyType,
        enablesReturnKeyAutomatically: enablesReturnKeyAutomatically,
        isSecureTextEntry: isSecureTextEntry
      )
    }
    
    set {
      textContentType = newValue.textContentType
      autocapitalizationType = newValue.autocapitalizationType
      autocorrectionType = newValue.autocorrectionType
      smartDashesType = newValue.smartDashesType
      smartInsertDeleteType = newValue.smartInsertDeleteType
      smartQuotesType = newValue.smartQuotesType
      spellCheckingType = newValue.spellCheckingType
      keyboardType = newValue.keyboardType
      keyboardAppearance = newValue.keyboardAppearance
      returnKeyType = newValue.returnKeyType
      enablesReturnKeyAutomatically = newValue.enablesReturnKeyAutomatically
      isSecureTextEntry = newValue.isSecureTextEntry
    }
  }
  
}
