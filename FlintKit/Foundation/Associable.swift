//
//  MIT License
//
//  Associable.swift
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
//  Modified from https://jobandtalent.engineering/the-power-of-mixins-in-swift-f9013254c503

import Foundation


public enum AssociationPolicy {
  case strong, copy, weak
  
  fileprivate var objcPolicy: objc_AssociationPolicy {
    switch self {
    case .strong: return .OBJC_ASSOCIATION_RETAIN_NONATOMIC
    case .copy: return .OBJC_ASSOCIATION_COPY_NONATOMIC
    case .weak: return .OBJC_ASSOCIATION_ASSIGN
    }
  }
}


/// Provides a nicer Associated Objects API.
///
/// Example of how to make a key:
///
///     private var myKey: UInt8 = 0
///
/// Example of how to get a value:
///
///     let value = associatedObjectInstance[&myKey]
public protocol Associable: class {
  func associatedObject<T>(for key: UnsafeRawPointer) -> T?
  func setAssociatedObject<T>(_ object: T, for key: UnsafeRawPointer, policy: AssociationPolicy)
}


public extension Associable {
  
  func associatedObject<T>(for key: UnsafeRawPointer) -> T? {
    return objc_getAssociatedObject(self, key) as? T
  }
  
  func setAssociatedObject<T>(_ object: T, for key: UnsafeRawPointer, policy: AssociationPolicy = .strong) {
    objc_setAssociatedObject(self, key, object, policy.objcPolicy)
  }
  
}
