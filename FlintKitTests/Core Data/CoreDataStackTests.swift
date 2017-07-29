//
//  MIT License
//
//  CoreDataStackTests.swift
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
import FlintKit
import Foundation
import XCTest


class CoreDataStackTests: XCTestCase {
  
  // MARK: - Test Lifecycle
  
  override func tearDown() {
    super.tearDown()
    
    frcDelegate = nil
  }
  
  
  // MARK: - Private Properties
  
  fileprivate var frcDelegate: FRCDelegate?
  
  
  // MARK: - Tests
  
  func testIsMigrationNeeded_noExistingStore() {
    let configuration = SQLiteWithNoExistingStoreConfiguration()
    XCTAssertFalse(try CoreDataStack.isMigrationNeeded(for: configuration))
  }
  
  func testNewBackgroundContext_changesPropogateToMainContext() {
    do {
      let configuration = SimpleInMemoryConfiguration()
      let stack = try CoreDataStack(configuration: configuration)
      
      let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Entity")
      fetchRequest.sortDescriptors = [NSSortDescriptor(key: "myProperty", ascending: true)]
      let fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: stack.mainContext, sectionNameKeyPath: nil, cacheName: nil)
      try fetchedResultsController.performFetch()
      
      let expectation = self.expectation(description: "frc has content")
      frcDelegate = FRCDelegate(expectation: expectation)
      fetchedResultsController.delegate = frcDelegate
      
      let background = stack.newBackgroundContext()
      background.performAndWait {
        let object = NSEntityDescription.insertNewObject(forEntityName: "Entity", into: background)
        object.setValue("value", forKey: "myProperty")
        _ = try? background.save()
      }
      
      waitForExpectations(timeout: 0.1, handler: nil)
      
      XCTAssertEqual(fetchedResultsController.fetchedObjects?.count, 1)
    } catch {
      XCTFail("\(error)")
    }
  }
  
}


private struct SQLiteWithNoExistingStoreConfiguration: CoreDataStackConfigurationType {
  
  // MARK: - Enum
  
  enum SQLiteWithNoExistingStoreConfigurationError: Error {
    case genericError
  }
  
  let managedObjectModel = NSManagedObjectModel()
  let persistentStoreType: CoreDataStack.PersistentStoreType = {
    let url = URL(fileURLWithPath: NSTemporaryDirectory())
      .appendingPathComponent(NSUUID().uuidString, isDirectory: false)
      .appendingPathExtension("sqlite")
    return .sqLite(storeUrl: url)
  }()
  
  func destinationModel(forSourceModelContainer container: CoreDataStackSourceModelContainer) throws -> NSManagedObjectModel {
    throw SQLiteWithNoExistingStoreConfigurationError.genericError
  }
  
  fileprivate func mappingModels(fromSource source: NSManagedObjectModel, toDestination destination: NSManagedObjectModel) throws -> [NSMappingModel] {
    throw SQLiteWithNoExistingStoreConfigurationError.genericError
  }
}


private struct SimpleInMemoryConfiguration: CoreDataStackConfigurationType {
  
  enum SimpleInMemoryConfigurationError: Error {
    case genericError
  }
  
  let managedObjectModel: NSManagedObjectModel = {
    let property = NSAttributeDescription()
    property.attributeType = .stringAttributeType
    property.name = "myProperty"
    
    let entity = NSEntityDescription()
    entity.managedObjectClassName = "NSManagedObject"
    entity.name = "Entity"
    entity.properties = [property]
    
    let model = NSManagedObjectModel()
    model.entities = [entity]
    return model
  }()
  
  let persistentStoreType: CoreDataStack.PersistentStoreType = .inMemory
  
  fileprivate func destinationModel(forSourceModelContainer container: CoreDataStackSourceModelContainer) throws -> NSManagedObjectModel {
    throw SimpleInMemoryConfigurationError.genericError
  }
  
  fileprivate func mappingModels(fromSource source: NSManagedObjectModel, toDestination destination: NSManagedObjectModel) throws -> [NSMappingModel] {
    throw SimpleInMemoryConfigurationError.genericError
  }
  
}

private class FRCDelegate: NSObject, NSFetchedResultsControllerDelegate {
  
  init(expectation: XCTestExpectation) {
    self.expectation = expectation
  }
  
  fileprivate let expectation: XCTestExpectation
  
  @objc fileprivate func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
    expectation.fulfill()
  }
  
}
