//
//  Bundle+CoreData+FlintKit.swift
//  Pods
//
//  Created by Extinguish on 7/10/17.
//
//

import CoreData
import Foundation


extension Bundle {
  
  func path(forManagedObjectModelSourceMetadata metadata: [String: Any]) -> URL? {
    let momdPaths = paths(forResourcesOfType: "momd", inDirectory: nil)
    
    var modelPaths: [String] = momdPaths.flatMap { momdPath -> [String] in
      let directory = (momdPath as NSString).lastPathComponent
      return paths(forResourcesOfType: "mom", inDirectory: directory)
    }
    
    // Add any paths of "mom" files in the top level. This can happen if the bundle is the momd directory.
    modelPaths.append(contentsOf: paths(forResourcesOfType: "mom", inDirectory: nil))
      
    for modelPath in modelPaths {
      let path = URL(fileURLWithPath: modelPath)
      guard
        let model = NSManagedObjectModel(contentsOf: path),
        model.isConfiguration(withName: nil, compatibleWithStoreMetadata: metadata) else {
          continue
      }
      
      
      return path
    }
    
    return nil
  }
  
}
