//
//  CoreDataStackSourceModelContainer.swift
//  Pods
//
//  Created by Extinguish on 7/10/17.
//
//

import CoreData
import Foundation


public struct CoreDataStackSourceModelContainer {
  
  // MARK: - Object Lifecycle
  
  public init(model: NSManagedObjectModel, metadata: [String: Any], path: URL) {
    self.model = model
    self.metadata = metadata
    self.path = path
  }
  
  
  // MARK: - Public Properties
  
  public let model: NSManagedObjectModel
  public let metadata: [String: Any]
  public let path: URL
  
}
