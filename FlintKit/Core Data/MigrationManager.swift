//
//  MIT License
//
//  MigrationManager.swift
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

import CoreData
import Foundation


final class MigrationManager {
  
  // MARK: - Enum
  
  fileprivate enum MigrationManagerError: Error {
    case unknownStorePathAndExtension
  }
  
  // MARK: - Internal Methods
  
  func migrate(configuration: CoreDataStackConfigurationType) throws {
    switch configuration.persistentStoreType {
    case .inMemory: return // No migration needed.
    case .sqLite(let storeUrl):
      try progressivelyMigrate(sourceStoreUrl: storeUrl, withConfiguration: configuration)
    }
  }
  
  
  // MARK: - Private Methods
  
  fileprivate func progressivelyMigrate(sourceStoreUrl: URL, withConfiguration configuration: CoreDataStackConfigurationType) throws {
    let type = configuration.persistentStoreType.value
    let sourceMetadata = try NSPersistentStoreCoordinator.metadataForPersistentStore(ofType: type, at: sourceStoreUrl)
    
    guard !configuration.managedObjectModel.isConfiguration(withName: nil, compatibleWithStoreMetadata: sourceMetadata) else {
      // No migration needed.
      return
    }
    
    let sourceModelContainer = try configuration.sourceModelContainer(forSourceMetadata: sourceMetadata)
    
    let destinationModel = try configuration.destinationModel(forSourceModelContainer: sourceModelContainer)
    let destinationUrl = try destinationStoreUrl(sourceStoreUrl: sourceStoreUrl)
    let mappingModels = try configuration.mappingModels(fromSource: sourceModelContainer.model, toDestination: destinationModel)
    
    let manager = NSMigrationManager(sourceModel: sourceModelContainer.model, destinationModel: destinationModel)
    
    for mappingModel in mappingModels {
      try manager.migrateStore(from: sourceStoreUrl, sourceType: type, options: nil, with: mappingModel, toDestinationURL: destinationUrl, destinationType: type, destinationOptions: nil)
    }
    
    var resultingItemUrl: NSURL?
    try FileManager.default.replaceItem(at: sourceStoreUrl, withItemAt: destinationUrl, backupItemName: nil, options: [.usingNewMetadataOnly], resultingItemURL: &resultingItemUrl)
    
    let newSourceStoreUrl = (resultingItemUrl as URL?) ?? sourceStoreUrl
    try progressivelyMigrate(sourceStoreUrl: newSourceStoreUrl, withConfiguration: configuration)
  }
  
}


// MARK: - Private Helpers

private func destinationStoreUrl(sourceStoreUrl sourceUrl: URL) throws -> URL {
  let fullStorePath = sourceUrl.path as NSString?
  guard
    let storeExtension = fullStorePath?.pathExtension,
    let storePath = fullStorePath?.deletingPathExtension else {
      throw MigrationManager.MigrationManagerError.unknownStorePathAndExtension
  }
  
  let newPath = "\(storePath).intermediate.\(storeExtension)"
  return URL(fileURLWithPath: newPath)
}
