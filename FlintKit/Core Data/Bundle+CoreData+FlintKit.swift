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
    var momdPaths = paths(forResourcesOfType: "momd", inDirectory: nil) as [NSString]
    
    if
      let resourceURL = resourceURL,
      resourceURL.pathExtension == "momd" {
      // This bundle _is_ a momd directory.
      momdPaths.append(resourceURL.path as NSString)
    }
    
    for momdPath in momdPaths {
      let directory = momdPath.lastPathComponent
      let modelPaths = paths(forResourcesOfType: "mom", inDirectory: directory)
      
      for modelPath in modelPaths {
        let path = URL(fileURLWithPath: modelPath)
        guard
          let model = NSManagedObjectModel(contentsOf: path),
          model.isConfiguration(withName: nil, compatibleWithStoreMetadata: metadata) else {
            continue
        }
        
        
        return path
      }
    }
    
    return nil
  }
  
}
