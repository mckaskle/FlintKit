//
//  MIT License
//
//  CFStringTests.swift
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


class CFStringTests: XCTestCase {
  
  // MARK: - Tests
  
  func testCFString_EqualTo() {
    XCTAssert("a" as CFString == "a" as CFString)
    XCTAssert("Hello World" as CFString == "Hello World" as CFString)
  }
  
  func testCFString_NotEqualTo() {
    XCTAssert("a" as CFString != "b" as CFString)
    XCTAssert("a" as CFString != "A" as CFString)
    XCTAssert("Hello World" as CFString != "Hellø Wørld" as CFString)
    XCTAssert("Hi!" as CFString != "Hi" as CFString)
    XCTAssert("Hi!" as CFString != "Hi!  " as CFString)
    XCTAssert("" as CFString != " " as CFString)
    XCTAssert("a" as CFString != "a\n" as CFString)
  }
  
  func testCFString_LessThan() {
    XCTAssert(("a" as CFString) < ("b" as CFString))
    XCTAssert(("A" as CFString) < ("B" as CFString))
    XCTAssert(("Hello" as CFString) < ("Hi" as CFString))
  }
  
  func testCFString_LessThanEqualTo() {
    // less than
    XCTAssert(("a" as CFString) <= ("b" as CFString))
    XCTAssert(("A" as CFString) <= ("B" as CFString))
    XCTAssert(("Hello" as CFString) <= ("Hi" as CFString))
    // equal to
    XCTAssert(("a" as CFString) <= ("a" as CFString))
    XCTAssert(("Hello World" as CFString) <= ("Hello World" as CFString))
  }
  
  func testCFString_GreaterThan() {
    XCTAssert(("b" as CFString) > ("a" as CFString))
    XCTAssert(("B" as CFString) > ("A" as CFString))
    XCTAssert(("Hi" as CFString) > ("Hello" as CFString))
  }
  
  func testCFString_GreaterThanEqualTo() {
    // greater than
    XCTAssert(("b" as CFString) >= ("a" as CFString))
    XCTAssert(("B" as CFString) >= ("A" as CFString))
    XCTAssert(("Hi" as CFString) >= ("Hello" as CFString))
    // equal to
    XCTAssert(("a" as CFString) >= ("a" as CFString))
    XCTAssert(("Hello World" as CFString) >= ("Hello World" as CFString))
  }
  
}
