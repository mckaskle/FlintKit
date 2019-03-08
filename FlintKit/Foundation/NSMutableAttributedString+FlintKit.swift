//
//  MIT License
//
//  NSMutableAttributedString+FlintKit.swift
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

import Foundation


extension NSMutableAttributedString {
  
  // MARK: - Public Methods
  
  /// If `attributes` parameter is `nil`, the attributes of the last character in the existing string is used.
  public func append(string: String, attributes: [NSAttributedString.Key: Any]? = nil) {
    var attributes = attributes
    
    if attributes == nil {
      // If explicit attributes are not given, the attributes of the end of the string are used.
      let range = NSRangeFromString(string)
      enumerateAttributes(in: range, options: [.reverse, .longestEffectiveRangeNotRequired]) { (attrs, _, stop) in
        attributes = attrs
        stop.pointee = true
      }
    }
    
    append(NSAttributedString(string: string, attributes: attributes))
  }
  
}
