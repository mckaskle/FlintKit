//
//  MIT License
//
//  FetchedResultsControllerTableViewDataSource.swift
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
import UIKit


public protocol FetchedResultsControllerTableViewDataSourceDelegate: class {
  associatedtype ItemType: NSManagedObject
  associatedtype CellType: UITableViewCell
  
  func fetchedResultsControllerTableViewDataSource(_ dataSource: FetchedResultsControllerTableViewDataSource<ItemType, CellType, Self>, configureCell cell: CellType, forItem item: ItemType, atIndexPath indexPath: IndexPath)
  
  func fetchedResultsControllerTableViewDataSource(_ dataSource: FetchedResultsControllerTableViewDataSource<ItemType, CellType, Self>, commitDeleteForItem item: ItemType, atIndexPath indexPath: IndexPath)
  
  func fetchedResultsControllerTableViewDataSource(_ dataSource: FetchedResultsControllerTableViewDataSource<ItemType, CellType, Self>, canEditItem item: ItemType, atIndexPath indexPath: IndexPath) -> Bool
  
  func fetchedResultsControllerTableViewDataSourceDidUpdateContent(_ dataSource: FetchedResultsControllerTableViewDataSource<ItemType, CellType, Self>)
}

public extension FetchedResultsControllerTableViewDataSourceDelegate {
  
  func fetchedResultsControllerTableViewDataSource(_ dataSource: FetchedResultsControllerTableViewDataSource<ItemType, CellType, Self>, commitDeleteForItem item: ItemType, atIndexPath indexPath: IndexPath) {
    assertionFailure("By default, table view items cannot be edited. If you change this default, commitDeleteForItem must be implemented.")
  }
  
  func fetchedResultsControllerTableViewDataSource(_ dataSource: FetchedResultsControllerTableViewDataSource<ItemType, CellType, Self>, canEditItem item: ItemType, atIndexPath indexPath: IndexPath) -> Bool {
    return false
  }
  
  func fetchedResultsControllerTableViewDataSourceDidUpdateContent(_ dataSource: FetchedResultsControllerTableViewDataSource<ItemType, CellType, Self>) {
    // No-op.
  }
  
}


final public class FetchedResultsControllerTableViewDataSource<
  ItemType,
  CellType,
  Delegate: FetchedResultsControllerTableViewDataSourceDelegate>: NSObject, NSFetchedResultsControllerDelegate, UITableViewDataSource
  where ItemType == Delegate.ItemType,
  CellType == Delegate.CellType
 {
  
  // MARK: - Object Lifecycle
  
  public init(tableView: UITableView, controller: NSFetchedResultsController<ItemType>, delegate: Delegate) throws {
    self.tableView = tableView
    self.controller = controller
    self.delegate = delegate
    
    super.init()
    
    controller.delegate = self
    try controller.performFetch()
    tableView.reloadData()
  }
  
  
  // MARK: - Public Properties
  
  public var fetchedObjects: [ItemType] {
    return controller.fetchedObjects ?? []
  }
  
  
  // MARK: - Public Methods
  
  public func object(at indexPath: IndexPath) -> ItemType {
    return controller.object(at: indexPath)
  }
  
  
  // MARK: - Private Properties
  
  fileprivate weak var tableView: UITableView?
  fileprivate let controller: NSFetchedResultsController<ItemType>
  fileprivate weak var delegate: Delegate?
  
  
  // MARK: - NSFetchedResultsControllerDelegate
  
  public func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
    tableView?.beginUpdates()
  }
  
  public func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange sectionInfo: NSFetchedResultsSectionInfo, atSectionIndex sectionIndex: Int, for type: NSFetchedResultsChangeType) {
    let sections = IndexSet(integer: sectionIndex)
    
    switch type {
    case .insert:
      tableView?.insertSections(sections, with: .automatic)
      
    case .delete:
      tableView?.deleteSections(sections, with: .automatic)
      
    case .move, .update:
      assertionFailure("Invalid change type for section update.")
    }
  }
  
  public func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
    switch type {
    case .insert:
      guard let newIndexPath = newIndexPath else { return }
      tableView?.insertRows(at: [newIndexPath], with: .automatic)
      
    case .delete:
      guard let indexPath = indexPath else { return }
      tableView?.deleteRows(at: [indexPath], with: .automatic)
      
    case .update:
      guard let
        indexPath = indexPath,
        let cell = tableView?.cellForRow(at: indexPath) as? CellType else {
          return
      }
      
      let item = object(at: indexPath)
      delegate?.fetchedResultsControllerTableViewDataSource(self, configureCell: cell, forItem: item, atIndexPath: indexPath)
      
    case .move:
      // The item is moving because some data changed. Update the cell to reflect
      // the new changes before moving the cell.
      guard let indexPath = indexPath, let newIndexPath = newIndexPath else { return }
      if let cell = tableView?.cellForRow(at: indexPath) as? CellType {
        // Use the new index path since the object for the moving cell is already at the
        // new position in data model.
        let item = object(at: newIndexPath)
        delegate?.fetchedResultsControllerTableViewDataSource(self, configureCell: cell, forItem: item, atIndexPath: indexPath)
      }
      
      tableView?.moveRow(at: indexPath, to: newIndexPath)
    }
  }
  
  public func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
    tableView?.endUpdates()
    delegate?.fetchedResultsControllerTableViewDataSourceDidUpdateContent(self)
  }
  
  
  // MARK: - UITableViewDataSource
  
  public func numberOfSections(in tableView: UITableView) -> Int {
    return controller.sections?.count ?? 0
  }
  
  public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return controller.sections?[section].numberOfObjects ?? 0
  }
  
  public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueCell(for: indexPath) as CellType
    let item = object(at: indexPath)
    
    delegate?.fetchedResultsControllerTableViewDataSource(self, configureCell: cell, forItem: item, atIndexPath: indexPath)
    
    return cell
  }
  
  public func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
    let item = object(at: indexPath)
    return delegate?.fetchedResultsControllerTableViewDataSource(self, canEditItem: item, atIndexPath: indexPath) ?? false
  }
  
  public func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
    switch editingStyle {
    case .none:
      break
      
    case .insert:
      fatalError("Insertion support has not been added yet.")
      
    case .delete:
      let item = object(at: indexPath)
      delegate?.fetchedResultsControllerTableViewDataSource(self, commitDeleteForItem: item, atIndexPath: indexPath)
    }
  }
  
}
