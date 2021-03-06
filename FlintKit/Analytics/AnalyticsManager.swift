//
//  MIT License
//
//  AnalyticsManager.swift
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

import Foundation


public struct AnalyticsManager {
  
  // MARK: - Type Aliases
  
  /// Returns true if the error should be considered to be logged.
  public typealias ErrorFilter = (Error) -> Bool
  /// Token that is used when registering/unregistering ErrorFilters.
  public typealias ErrorFilterToken = UUID
  
  
  // MARK: - Object Lifecyle
  
  private init() {} // disable instantiations
  
  
  // MARK: - Public Properties
  
  public static var services: [AnalyticsService] = []
  
  /// These contain the errors that should not be logged.
  /// [NSErrorDomain: Set<Error Code>]
  public static var whiteListedErrors: [String: Set<Int>] = [
    NSURLErrorDomain: [
      NSURLErrorCancelled,
      NSURLErrorNetworkConnectionLost,
      NSURLErrorNotConnectedToInternet,
    ],
    // Undocumented, private errors that are returned when no Internet connection
    // is available and a product is requested from StoreKit.
    // http://www.openradar.me/25502597
    "SSErrorDomain": [
      110
    ]
  ]
  
  
  // MARK: - Public Methods
  
  public static func isErrorWhitelisted(_ error: Error) -> Bool {
    return whiteListedErrors[error._domain]?.contains(error._code) ?? false
  }
  
  public static func log(_ error: Error) {
    for filter in errorFilters.values {
      guard filter(error) else { return }
    }
    
    guard !isErrorWhitelisted(error) else { return }
    
    for service in services {
      service.log(error)
    }
  }
  
  /// ErrorFilters provide a way to filter errors before they are logged. This is useful
  /// when determining if an error should be logged is not as simple as checking the
  /// domain and error code. For errors that can be filtered simply by domain and error
  /// code, add them to `whiteListedErrors` instead.
  ///
  /// Returns a token that can later be used to unregister the filter.
  @discardableResult
  public static func register(errorFilter: @escaping ErrorFilter) -> ErrorFilterToken {
    let token = UUID()
    errorFilters[token] = errorFilter
    return token
  }
  
  public static func unregister(errorFilterToken: ErrorFilterToken) {
    errorFilters.removeValue(forKey: errorFilterToken)
  }
  
  
  // MARK: - Private Properties
  
  private static var errorFilters: [ErrorFilterToken: ErrorFilter] = [:]
  
}
