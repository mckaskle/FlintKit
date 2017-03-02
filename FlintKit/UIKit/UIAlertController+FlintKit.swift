//
//  MIT License
//
//  UIAlertController+FlintKit.swift
//
//  Copyright (c) 2016 Devin McKaskle
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


public extension UIAlertController {
  
  func addDoneAction(_ handler: ((UIAlertAction) -> Void)? = nil) {
    let action = UIAlertAction(title: NSLocalizedString("Done", tableName: "FlintKitLocalizable", comment: "Done button on alert view"), style: .default, handler: handler)
    addAction(action)
  }
  
  func addOkayAction(_ handler: ((UIAlertAction) -> Void)? = nil) {
    let action = UIAlertAction(title: NSLocalizedString("OK", tableName: "FlintKitLocalizable", comment: "OK button on alert view"), style: .default, handler: handler)
    addAction(action)
  }
  
  func addCancelAction(_ handler: ((UIAlertAction) -> Void)? = nil) {
    let action = UIAlertAction(title: NSLocalizedString("Cancel", tableName: "FlintKitLocalizable", comment: "Cancel button on alert view"), style: .cancel, handler: handler)
    addAction(action)
  }
  
}