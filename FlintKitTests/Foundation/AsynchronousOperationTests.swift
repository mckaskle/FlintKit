//
//  MIT License
//
//  AsynchronousOperationTests.swift
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

import FlintKit
import XCTest


private class AsynchronousRecorderOperation: AsynchronousOperation {
  
  // MARK: - Private Properties
  
  fileprivate let duration: TimeInterval = 0.001
  fileprivate var mainCalled = false
  fileprivate var mainExpectation: XCTestExpectation?
  fileprivate var completeOperationCalled = false
  
  
  // MARK: - AsynchronousOperation
  
  fileprivate override func main() {
    super.main()
    
    mainCalled = true
    mainExpectation?.fulfill()
    
    let delta = Int64(TimeInterval(NSEC_PER_SEC) * duration)
    let time = DispatchTime.now() + Double(delta) / Double(NSEC_PER_SEC)
    DispatchQueue.main.asyncAfter(deadline: time) {
      self.completeOperationCalled = true
      self.completeOperation()
    }
  }
  
}


class AsynchronousOperationTests: XCTestCase {
  
  func testIsAsynchronous() {
    let operation = AsynchronousOperation()
    XCTAssert(operation.isAsynchronous)
  }
  
  func testCompletion_doesNotCompleteUntilCompleteOperationIsCalled() {
    let operation = AsynchronousRecorderOperation()
    
    let expectation = self.expectation(description: "dependent run")
    let dependent = BlockOperation {
      XCTAssert(operation.completeOperationCalled)
      expectation.fulfill()
    }
    dependent.addDependency(operation)
    
    OperationQueue().addOperations([operation, dependent], waitUntilFinished: false)
    
    waitForExpectations(timeout: 0.1, handler: nil)
  }
  
  func testExecution_isExecutingReturnsTrueDuringExecution() {
    let operation = AsynchronousRecorderOperation()
    
    let expectation = self.expectation(description: "main")
    operation.mainExpectation = expectation
    OperationQueue().addOperation(operation)
    
    waitForExpectations(timeout: 0.1, handler: nil)
    XCTAssert(operation.isExecuting)
  }
  
  func testCancellation_mainIsNotCalled() {
    let operation = AsynchronousRecorderOperation()
    operation.cancel()
    
    let expectation = self.expectation(description: "completed")
    let dependent = BlockOperation { expectation.fulfill() }
    dependent.addDependency(operation)
    
    let queue = OperationQueue()
    queue.addOperations([operation, dependent], waitUntilFinished: false)
    
    waitForExpectations(timeout: 0.1, handler: nil)
    XCTAssertFalse(operation.mainCalled)
  }
  
}
