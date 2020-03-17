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
    case .sqLite(let storeURL):
      try progressivelyMigrate(sourceStoreURL: storeURL, withConfiguration: configuration)
    }
  }
  
  
  // MARK: - Private Methods
  
  fileprivate func progressivelyMigrate(sourceStoreURL: URL, withConfiguration configuration: CoreDataStackConfigurationType) throws {
    let type = configuration.persistentStoreType.value
    let sourceMetadata = try NSPersistentStoreCoordinator.metadataForPersistentStore(ofType: type, at: sourceStoreURL)
    
    guard !configuration.managedObjectModel.isConfiguration(withName: nil, compatibleWithStoreMetadata: sourceMetadata) else {
      // No migration needed.
      return
    }
    
    let sourceModelContainer = try configuration.sourceModelContainer(forSourceMetadata: sourceMetadata)
    
    let destinationModel = try configuration.destinationModel(forSourceModelContainer: sourceModelContainer)
    let intermediateURL = try destinationStoreUrl(sourceStoreUrl: sourceStoreURL)
    let mappingModels = try configuration.mappingModels(fromSource: sourceModelContainer.model, toDestination: destinationModel)
    
    let manager = NSMigrationManager(sourceModel: sourceModelContainer.model, destinationModel: destinationModel)
    
    for mappingModel in mappingModels {
      try manager.migrateStore(from: sourceStoreURL, sourceType: type, options: nil, with: mappingModel, toDestinationURL: intermediateURL, destinationType: type, destinationOptions: nil)
    }

    let fileManager = FileManager.default
    let resultingItemURL = try fileManager.replaceItemAt(sourceStoreURL, withItemAt: intermediateURL, options: [.usingNewMetadataOnly])
    
    let newSourceStoreURL = (resultingItemURL as URL?) ?? sourceStoreURL

    // When WAL option is used to create a persistent store, some extra files may have been created.
    // Copy those over too, if necessary.
    // https://stackoverflow.com/a/21099483/1223950
    for suffix in ["-shm", "-wal"] {
      // Copying from `destinationURL` to `newSourceStoreURL`.
      let suffixedIntermediateItemURL = URL(fileURLWithPath: intermediateURL.path + suffix)
      let suffixedNewItemURL = URL(fileURLWithPath: newSourceStoreURL.path + suffix)

      let suffixedIntermediateItemExists = fileManager.fileExists(atPath: suffixedIntermediateItemURL.path)
      let suffixedNewItemExists = fileManager.fileExists(atPath: suffixedNewItemURL.path)

      switch (suffixedIntermediateItemExists, suffixedNewItemExists) {
      case (true, true):
        // Both exist. Replace the original w/ the intermediate.
        let _ = try fileManager.replaceItemAt(suffixedNewItemURL, withItemAt: suffixedIntermediateItemURL)

      case (true, false):
        // Intermediate exists but there is no new one. Delete the original.
        try fileManager.moveItem(at: suffixedIntermediateItemURL, to: suffixedNewItemURL)

      case (false, true):
        // There is a new item, but it's not replacing anything. Just rename it.
        try fileManager.removeItem(at: suffixedNewItemURL)

      case (false, false):
        // Nothing to delete. Nothing to move.
        break
      }
    }

    try progressivelyMigrate(sourceStoreURL: newSourceStoreURL, withConfiguration: configuration)
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
