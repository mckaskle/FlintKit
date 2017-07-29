//
//  MIT License
//
//  CoreDataStack.swift
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


public protocol CoreDataStackConfigurationType {
  var managedObjectModel: NSManagedObjectModel { get }
  var persistentStoreType: CoreDataStack.PersistentStoreType { get }
  
  func sourceModelContainer(forSourceMetadata metadata: [String: Any]) throws -> CoreDataStackSourceModelContainer
  func destinationModel(forSourceModelContainer container: CoreDataStackSourceModelContainer) throws -> NSManagedObjectModel
  func mappingModels(fromSource source: NSManagedObjectModel, toDestination destination: NSManagedObjectModel) throws -> [NSMappingModel]
}


private enum CoreDataStackConfigurationTypeError: Error {
  case cannotFindSourceModel
}

extension CoreDataStackConfigurationType {
  
  public func sourceModelContainer(forSourceMetadata metadata: [String: Any]) throws -> CoreDataStackSourceModelContainer {
    print(Bundle.allBundles)
    for bundle in Bundle.allBundles {
      guard
        let path = bundle.path(forManagedObjectModelSourceMetadata: metadata),
        let model = NSManagedObjectModel(contentsOf: path) else {
          continue
      }
      
      return CoreDataStackSourceModelContainer(model: model, metadata: metadata, path: path)
    }
    
    throw CoreDataStackConfigurationTypeError.cannotFindSourceModel
  }
  
}


final public class CoreDataStack {
  
  // MARK: - Subtypes
  
  public struct DefaultConfiguration: CoreDataStackConfigurationType {
    
    // MARK: - Enum
    
    fileprivate enum CoreDataStackError: Error {
      case cannotLoadModelInit
      case cannotLoadModelDestinationBlock
    }
    
    
    // MARK: - Object Lifecycle
    
    public init() throws {
      guard let model = NSManagedObjectModel.mergedModel(from: nil) else {
        throw CoreDataStackError.cannotLoadModelInit
      }
      managedObjectModel = model
      
      let filename = "store.sqlite"
      let documentsDirectory = try FileManager.default.documentsDirectory()
      let url = documentsDirectory.appendingPathComponent(filename, isDirectory: false)
      persistentStoreType = .sqLite(storeUrl: url)
    }
    
    
    // MARK: - Public Properties
    
    public let managedObjectModel: NSManagedObjectModel
    public let persistentStoreType: CoreDataStack.PersistentStoreType
    
    public var destinationBlock: ((_ forContainer: CoreDataStackSourceModelContainer) throws -> NSManagedObjectModel) = { container in
      guard let model = NSManagedObjectModel.mergedModel(from: nil) else {
        throw CoreDataStackError.cannotLoadModelDestinationBlock
      }
      
      return model
    }
    
    public var mappingBlock: ((_ fromSource: NSManagedObjectModel, _ toDestination: NSManagedObjectModel) throws -> [NSMappingModel]) = { source, destination in
      return try [NSMappingModel.inferredMappingModel(forSourceModel: source, destinationModel: destination)]
    }
    
    public func destinationModel(forSourceModelContainer container: CoreDataStackSourceModelContainer) throws -> NSManagedObjectModel {
      return try destinationBlock(container)
    }
    
    public func mappingModels(fromSource source: NSManagedObjectModel, toDestination destination: NSManagedObjectModel) throws -> [NSMappingModel] {
      return try mappingBlock(source, destination)
    }
    
  }
  
  
  // MARK: - Enum
  
  public enum PersistentStoreType {
    case sqLite(storeUrl: URL), inMemory
    
    var value: String {
      switch self {
      case .sqLite:
        return NSSQLiteStoreType
        
      case .inMemory:
        return NSInMemoryStoreType
      }
    }
    
    fileprivate var storeUrl: URL? {
      switch self {
      case .inMemory: return nil
      case .sqLite(let storeUrl): return storeUrl
      }
    }
  }
  
  
  // MARK: - Object Lifecycle
  
  public convenience init() throws {
    let configuration = try DefaultConfiguration()
    try self.init(configuration: configuration)
  }
  
  public init(configuration: CoreDataStackConfigurationType) throws {
    self.configuration = configuration
    
    let options: [String: Any]
    if try type(of: self).isMigrationNeeded(for: configuration) {
      options = [
        NSInferMappingModelAutomaticallyOption: true,
        NSSQLitePragmasOption: ["journal_mode": "DELETE"]
      ]
    } else {
      options = [
        NSInferMappingModelAutomaticallyOption: true,
        NSSQLitePragmasOption: ["journal_mode": "WAL"]
      ]
    }
    
    persistentStoreCoordinator = NSPersistentStoreCoordinator(managedObjectModel: configuration.managedObjectModel)
    try persistentStoreCoordinator.addPersistentStore(ofType: configuration.persistentStoreType.value, configurationName: nil, at: configuration.persistentStoreType.storeUrl, options: options)
    
    mainContext = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
    mainContext.persistentStoreCoordinator = persistentStoreCoordinator
  }
  
  deinit {
    NotificationCenter.default.removeObserver(self)
  }
  
  
  // MARK: - Public Properties
  
  public let mainContext: NSManagedObjectContext
  
  
  // MARK: - Public Methods
  
  public class func isMigrationNeeded(for configuration: CoreDataStackConfigurationType) throws -> Bool {
    switch configuration.persistentStoreType {
    case .inMemory: return false
    case let .sqLite(storeUrl):
      // Migration is not necessary if there is no store yet.
      // We need to check for this scenario because otherwise
      // an error will be thrown.
      let path = storeUrl.path
      guard FileManager.default.fileExists(atPath: path) else { return false }
      
      let sourceMetadata = try NSPersistentStoreCoordinator.metadataForPersistentStore(ofType: configuration.persistentStoreType.value, at: storeUrl)
      return !configuration.managedObjectModel.isConfiguration(withName: nil, compatibleWithStoreMetadata: sourceMetadata)
    }
  }
  
  public class func migrate(with configuration: CoreDataStackConfigurationType) throws {
    let migrationManager = MigrationManager()
    try migrationManager.migrate(configuration: configuration)
  }
  
  public func newBackgroundContext() -> NSManagedObjectContext {
    let context = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
    context.persistentStoreCoordinator = persistentStoreCoordinator
    
    NotificationCenter.default.addObserver(self, selector: #selector(backgroundContextDidSave), name: NSNotification.Name.NSManagedObjectContextDidSave, object: context)
    
    return context
  }
  
  
  // MARK: - Private Properties
  
  fileprivate let configuration: CoreDataStackConfigurationType
  fileprivate let persistentStoreCoordinator: NSPersistentStoreCoordinator
  
  
  // MARK: - Actions
  
  @objc dynamic fileprivate func backgroundContextDidSave(_ notification: Notification) {
    CoreDataStack.mergeChangesFrom(notification, into: mainContext)
  }
  
  
  // MARK: - Private Methods
  
  fileprivate class func mergeChangesFrom(_ notification: Notification, into context: NSManagedObjectContext) {
    // https://gist.github.com/mikeabdullah/faa6fd7a75c04e7f9f9c
    // NSManagedObjectContext's merge routine ignores updated objects which aren't
    // currently faulted in. To force it to notify interested clients that such
    // objects have been refreshed (e.g. NSFetchedResultsController) we need to
    // force them to be faulted in ahead of the merge
    
    if let updated = (notification as NSNotification).userInfo?[NSUpdatedObjectsKey] as? Set<NSManagedObject> {
      let updatedIds = updated.map { $0.objectID }
      
      context.perform {
        for id in updatedIds {
          // The objects can't be a fault. -existingObjectWithID:error: is a
          // nice easy way to achieve that in a single swoop.
          _ = try? context.existingObject(with: id)
        }
        
        context.mergeChanges(fromContextDidSave: notification)
      }
    }
  }
  
}
