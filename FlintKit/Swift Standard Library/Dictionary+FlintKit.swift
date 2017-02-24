//
//  Dictionary+FlintKit.swift
//  FlintKit
//
//  Created by The Good App Company on 2/23/17.
//  Copyright © 2017 Castle And King. All rights reserved.
//

import Foundation


public extension Dictionary where Key: ExpressibleByStringLiteral {
  
  func formURLEncoded() -> String {
    let allowed = CharacterSet.urlQueryAllowed
    let pairs: [String] = flatMap { key, value in
      guard
        let escapedKey = String(describing: key).addingPercentEncoding(withAllowedCharacters: allowed),
        let escapedValue = String(describing: value).addingPercentEncoding(withAllowedCharacters: allowed) else {
          return nil
      }
      
      return "\(escapedKey)=\(escapedValue)"
    }
    
    return pairs.joined(separator: "&")
  }
  
}
