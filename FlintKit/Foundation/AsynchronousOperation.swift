//
//  MIT License
//
//  AsynchronousOperation.swift
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


open class AsynchronousOperation: Operation {
  
  // MARK: - Enum
  
  fileprivate enum State {
    case initial, executing, finished
    
    var key: String {
      switch self {
      case .initial: return ""
      case .executing: return "isExecuting"
      case .finished: return "isFinished"
      }
    }
    
    var executing: Bool {
      switch self {
      case .executing: return true
      case .initial, .finished: return false
      }
    }
    
    var finished: Bool {
      switch self {
      case .finished: return true
      case .initial, .executing: return false
      }
    }
    
  }
  
  
  // MARK: - Public Methods
  
  /// Call this function to signal to the system that execution of the operation
  /// has completed.
  open func completeOperation() {
    state = .finished
  }
  
  
  // MARK: - Private Properties
  
  fileprivate var state = State.initial {
    willSet {
      assert(newValue != .initial, "Should never move back to the Initial State.")
      willChangeValue(forKey: state.key)
      willChangeValue(forKey: newValue.key)
    }
    didSet {
      didChangeValue(forKey: oldValue.key)
      didChangeValue(forKey: state.key)
    }
  }
  
  
  // MARK: - NSOperation
  
  open override var isAsynchronous: Bool { return true }
  open override var isExecuting: Bool { return state.executing }
  open override var isFinished: Bool { return state.finished }
  
  
  open override func start() {
    guard !isCancelled else {
      state = .finished
      return
    }
    
    state = .executing
    main()
  }
  
  /// Override this method with work to do. It will be called automatically
  /// if it's appropriate, based on state (e.g. cancelled operations will not
  /// have main() called.
  open override func main() { }
  
}
