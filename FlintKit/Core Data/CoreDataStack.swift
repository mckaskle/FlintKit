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
import UIKit


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
      let filename = "store.sqlite"
      let documentsDirectory = try FileManager.default.documentsDirectory()
      let url = documentsDirectory.appendingPathComponent(filename, isDirectory: false)
      
      try self.init(persistentStoreType: .sqLite(storeURL: url))
    }
    
    public init(modelBundles: [Bundle] = [.main], persistentStoreType: CoreDataStack.PersistentStoreType) throws {
      guard let model = NSManagedObjectModel.mergedModel(from: modelBundles) else {
        throw CoreDataStackError.cannotLoadModelInit
      }
      managedObjectModel = model
      
      self.persistentStoreType = persistentStoreType
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
    case sqLite(storeURL: URL), inMemory
    
    var value: String {
      switch self {
      case .sqLite:
        return NSSQLiteStoreType
        
      case .inMemory:
        return NSInMemoryStoreType
      }
    }
    
    fileprivate var storeURL: URL? {
      switch self {
      case .inMemory: return nil
      case .sqLite(let storeURL): return storeURL
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
    try persistentStoreCoordinator.addPersistentStore(ofType: configuration.persistentStoreType.value, configurationName: nil, at: configuration.persistentStoreType.storeURL, options: options)
    
    mainContext = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
    mainContext.persistentStoreCoordinator = persistentStoreCoordinator
  }
  
  deinit {
    NotificationCenter.default.removeObserver(self)
  }
  
  
  // MARK: - Public Properties
  
  public let mainContext: NSManagedObjectContext
  
  
  // MARK: - Public Methods
  
  /// Will migrate the data stack if needed in the background while showing the
  /// `launchViewController`. Whether the migration is needed or not, the
  /// `postMigrationConfigurationHandler` will be called to give the caller a
  /// chance to set up the rootViewController or any other set up necessary
  /// before animating away from the `launchViewController`.
  ///
  /// If the migration fails, the user will be presented with an alert that
  /// explains the app could not be launched. When the user taps "OK", the app
  /// will forcibly exit.
  ///
  /// - Parameters:
  ///   - with: the data stack's configuration
  ///   - launchViewController: a VC that should be shown while the migration is
  ///     occurring.
  ///   - animationDuration: the amount of time it should take to hide the
  ///     `launchViewController`
  ///   - postMigrationConfigurationHandler: a block of code that should run
  ///     after the migration has completed to set up the main app VC. One thing
  ///     this handler might do is set up the rootViewController of the key
  ///     window now that the data stack has been migrated.
  ///   - completion: a handler that is run at the very end of the migration.
  ///     This is called regardless of if the migration or the
  ///     `postMigrationConfigurationHandler` succeeds or fails.
  public class func migrateIfNeeded(with configuration: CoreDataStackConfigurationType,
                                    launchViewController: UIViewController,
                                    animationDuration: TimeInterval = 0.3,
                                    postMigrationConfigurationHandler: @escaping () throws -> Void,
                                    completion: @escaping (_ result: SimpleResult) -> Void) {
    // Set up the launch window above the key window so that we can load the persistent
    // container.
    let launchWindow = UIWindow()
    launchWindow.windowLevel = .statusBar
    launchWindow.rootViewController = launchViewController
    launchWindow.isHidden = false
    
    func handleLaunchError(_ error: Error) {
      // Dispatch to next run loop in case the launch window hasn't been set up yet.
      DispatchQueue.main.async {
        let alert = UIAlertController(
          title: .couldNotLaunchApp,
          message: .theAppWillNowQuit,
          preferredStyle: .alert
        )
        alert.addOkayAction { (_) in
          exit(1)
        }
        launchWindow.rootViewController?.present(alert, animated: true, completion: nil)
        
        completion(.failure(error))
      }
    }
    
    DispatchQueue.global(qos: .userInitiated).async {
      do {
        if try CoreDataStack.isMigrationNeeded(for: configuration) {
          try CoreDataStack.migrate(with: configuration)
        }
        
        DispatchQueue.main.async {
          do {
            try postMigrationConfigurationHandler()
            
            // Now that the root view controller is set up, hide the launch window.
            let animator = UIViewPropertyAnimator(duration: animationDuration, dampingRatio: 1) {
              launchWindow.alpha = 0
            }
            animator.addCompletion { (_) in
              launchWindow.isHidden = true
              completion(.success)
            }
            animator.startAnimation()
          } catch {
            handleLaunchError(error)
          }
        }
      } catch {
        handleLaunchError(error)
      }
    }
  }
  
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
  
  public func performBackgroundTask(_ block: @escaping (NSManagedObjectContext) -> Void) {
    let context = newBackgroundContext()
    context.perform { block(context) }
  }
  
  public func deleteAllData() throws {
    guard let url = configuration.persistentStoreType.storeURL else { return }
    
    let existingStore = persistentStoreCoordinator.persistentStore(for: url)
    try persistentStoreCoordinator.destroyPersistentStore(
      at: url,
      ofType: configuration.persistentStoreType.value,
      options: existingStore?.options
    )
    
    let options: [String: Any] = [
      NSInferMappingModelAutomaticallyOption: true,
      NSSQLitePragmasOption: ["journal_mode": "WAL"]
    ]
    try persistentStoreCoordinator.addPersistentStore(
      ofType: configuration.persistentStoreType.value,
      configurationName: nil,
      at: url,
      options: options
    )
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
