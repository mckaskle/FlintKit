//
//  MIT License
//
//  NetworkActivityIndicatorManager.swift
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
import UIKit


@available(iOS 10.0, *)
@available(iOSApplicationExtension, unavailable)
public final class NetworkActivityIndicatorManager {
  
  // MARK: - Enum
  
  private enum State {
    case notActive, delayingStart, active, delayingEnd
  }
  
  
  // MARK: - Object Lifecycle
  
  init(application: UIApplication) {
    self.application = application
  }
  
  
  // MARK: - Public Properties
  
  static public let shared = NetworkActivityIndicatorManager(application: .shared)
  
  
  // MARK: - Public Methods
  
  public func incrementActivityCount() {
    let f = { self.activityCount += 1 }
    if Thread.isMainThread {
      f()
    } else {
      DispatchQueue.main.async(execute: f)
    }
  }
  
  public func decrementActivityCount() {
    let f = { self.activityCount = max(0, self.activityCount - 1) }
    if Thread.isMainThread {
      f()
    } else {
      DispatchQueue.main.async(execute: f)
    }
  }
  
  
  // MARK: - Private Properties
  
  private let application: UIApplication
  
  private var startTimer: Timer?
  private var endTimer: Timer?
  
  private var activityCount = 0 {
    didSet {
      switch state {
      case .notActive:
        if activityCount > 0 {
          state = .delayingStart
        }
        
      case .delayingStart:
        // No-op, let the timer finish.
        break
        
      case .active:
        if activityCount <= 0 {
          state = .delayingEnd
        }
        
      case .delayingEnd:
        if activityCount > 0 {
          state = .active
        }
      }
    }
  }
  
  private var state: State = .notActive {
    didSet {
      switch state {
      case .notActive:
        startTimer?.invalidate()
        endTimer?.invalidate()
        application.isNetworkActivityIndicatorVisible = false
        
      case .delayingStart:
        // Apple's HIG describes the following:
        //   > Display the network activity indicator to provide feedback when your app accesses
        //   > the network for more than a couple of seconds. If the operation finishes sooner
        //   > than that, you don’t have to show the network activity indicator, because the
        //   > indicator is likely to disappear before users notice its presence.
        startTimer = .scheduledTimer(withTimeInterval: 1, repeats: false) { [weak self] _ in
          guard let s = self else { return }
          s.state = s.activityCount > 0 ? .active : .notActive
        }
        
      case .active:
        endTimer?.invalidate()
        application.isNetworkActivityIndicatorVisible = true
        
      case .delayingEnd:
        endTimer?.invalidate()
        // Delay hiding the indicator so that if multiple requests are happening one after another,
        // there is one continuous showing of the network indicator.
        endTimer = .scheduledTimer(withTimeInterval: 0.17, repeats: false) { [weak self] _ in
          self?.state = .notActive
        }
      }
    }
  }
  
}
