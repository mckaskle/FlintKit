//
//  Assert.swift
//  FlintKit
//
//  Created by Ranger on 6/22/17.
//  Copyright © 2017 Devin McKaskle. All rights reserved.
//

import Foundation


/**
 Asserts that two expressions have the same `dump` output.
 
 - Note: Like the standard library's `assert`, the
 assertion is only active in playgrounds and `-Onone`
 builds. The function does nothing in optimized builds.
 - Seealso: `dump(_:to:name:indent:maxDepth:maxItems)`
 - Author: https://oleb.net/blog/2017/03/dump-as-equatable-safeguard/
 */
public func assertDumpsEqual<T>(_ lhs: @autoclosure () -> T,
                      _ rhs: @autoclosure () -> T,
                      file: StaticString = #file, line: UInt = #line) {
  assert(String(dumping: lhs()) == String(dumping: rhs()),
         "Expected dumps to be equal.",
         file: file, line: line)
}
