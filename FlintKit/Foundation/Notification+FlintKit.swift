//
//  MIT License
//
//  Notification+FlintKit.swift
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
import UIKit


public extension Notification {
  
  var keyboardAnimationDuration: TimeInterval? {
    let duration = userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? NSNumber
    return duration?.doubleValue
  }
  
  var keyboardAnimationOptions: UIView.AnimationOptions {
    guard let curveNumber = userInfo?[UIResponder.keyboardAnimationCurveUserInfoKey] as? NSNumber else { return [] }
    let curveInt = curveNumber.intValue
    // NOTE: The following curve can be created even if the curveInt is invalid. If this happens, it leads to a crash.
    // Therefore a manual guard is put in to ensure the curveInt is not out of bounds.
    guard curveInt < 4 else { return [] }
    guard let curve = UIView.AnimationCurve(rawValue: curveInt) else { return [] }
    
    switch curve {
    case .easeIn: return [.curveEaseIn]
    case .easeInOut: return [.curveEaseInOut]
    case .easeOut: return [.curveEaseOut]
    case .linear: return [.curveLinear]
    }
  }
  
  var keyboardFrameBegin: CGRect? {
    let value = userInfo?[UIResponder.keyboardFrameBeginUserInfoKey] as? NSValue
    return value?.cgRectValue
  }
  
  var keyboardFrameEnd: CGRect? {
    let value = userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue
    return value?.cgRectValue
  }
  
}
