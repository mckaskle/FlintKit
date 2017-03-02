//
//  MIT License
//
//  StringTests.swift
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


class OptionalTests: XCTestCase {
  
  // MARK: - Tests
  
  func testNonNil_some() {
    let test: String? = "test"
    XCTAssertEqual(test.nonNil(), "test")
  }
  
  func testNonNil_none() {
    let test: String? = nil
    XCTAssertEqual(test.nonNil(), "")
  }
  
  func testNonNil_fallback_some() {
    let test: String? = "test"
    XCTAssertEqual(test.nonNil(fallback: "different"), "test")
  }
  
  func testNonNil_fallback_none() {
    let test: String? = nil
    XCTAssertEqual(test.nonNil(fallback: "different"), "different")
  }
  
}
