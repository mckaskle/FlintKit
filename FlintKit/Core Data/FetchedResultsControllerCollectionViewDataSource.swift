//
//  MIT License
//
//  FetchedResultsControllerCollectionViewDataSource.swift
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


public protocol FetchedResultsControllerCollectionViewDataSourceDelegate: class {
  associatedtype ItemType: NSManagedObject
  associatedtype CellType: UICollectionViewCell
  
  func fetchedResultsControllerCollectionViewDataSource(_ dataSource: FetchedResultsControllerCollectionViewDataSource<ItemType, CellType, Self>, configureCell cell: CellType, forItem item: ItemType, atIndexPath indexPath: IndexPath)
  
  func fetchedResultsControllerCollectionViewDataSource(_ dataSource: FetchedResultsControllerCollectionViewDataSource<ItemType, CellType, Self>, canMoveItemAt indexPath: IndexPath) -> Bool
  
  func fetchedResultsControllerCollectionViewDataSource(_ dataSource: FetchedResultsControllerCollectionViewDataSource<ItemType, CellType, Self>, moveItemAtIndexPath sourceIndexPath: IndexPath, toIndexPath destinationIndexPath: IndexPath)
  
  func fetchedResultsControllerCollectionViewDataSourceDidUpdateContent(_ dataSource: FetchedResultsControllerCollectionViewDataSource<ItemType, CellType, Self>)
  
  func fetchedResultsControllerCollectionViewDataSource(_ dataSource: FetchedResultsControllerCollectionViewDataSource<ItemType, CellType, Self>, collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView?
}


public extension FetchedResultsControllerCollectionViewDataSourceDelegate {
  
  func fetchedResultsControllerCollectionViewDataSource(_ dataSource: FetchedResultsControllerCollectionViewDataSource<ItemType, CellType, Self>, canMoveItemAt indexPath: IndexPath) -> Bool {
    return true
  }
  
}


// MARK: - Enum

private enum Change {
  case sectionInsert(Int)
  case sectionDelete(Int)
  case objectInsert(IndexPath)
  case objectUpdate(IndexPath)
  case objectMove(IndexPath, IndexPath)
  case objectDelete(IndexPath)
}

private enum InteractiveMovementMode {
  case noMovement, movement(IndexPath)
}


final public class FetchedResultsControllerCollectionViewDataSource<
  ItemType,
  CellType,
  Delegate: FetchedResultsControllerCollectionViewDataSourceDelegate>: NSObject, NSFetchedResultsControllerDelegate, UICollectionViewDataSource
  where ItemType == Delegate.ItemType,
  CellType == Delegate.CellType
 {
  
  
  // MARK: - Object Lifecycle
  
  public init(
    collectionView: UICollectionView,
    controller: NSFetchedResultsController<ItemType>,
    delegate: Delegate) throws {
      self.collectionView = collectionView
      self.controller = controller
      self.delegate = delegate
      
      super.init()
      
      controller.delegate = self
      try controller.performFetch()
  }
  
  
  // MARK: - Public Methods
  
  public func object(at indexPath: IndexPath) -> ItemType {
    return controller.object(at: indexPath)
  }
  
  public func safeObject(at indexPath: IndexPath) -> ItemType? {
    let sections = controller.sections ?? []
    guard indexPath.section < sections.count else { return nil }
    let section = sections[indexPath.section]
    guard indexPath.item < section.numberOfObjects else { return nil }
    return object(at: indexPath)
  }
  
  /// Keep the data source up to date with the collection view's interactive
  /// movement in order to workaround some iOS bugs.
  public func beginInteractiveMovementForItemAtIndexPath(_ indexPath: IndexPath) {
    interactiveMovementMode = .movement(indexPath)
  }
  
  /// Keep the data source up to date with the collection view's interactive
  /// movement in order to workaround some iOS bugs.
  public func endInteractiveMovement() {
    interactiveMovementMode = .noMovement
  }
  
  
  // MARK: - Private Properties
  
  fileprivate weak var collectionView: UICollectionView?
  fileprivate let controller: NSFetchedResultsController<ItemType>
  fileprivate weak var delegate: Delegate?
  
  fileprivate var changes = [Change]()
  fileprivate var hadError = false
  fileprivate var isProgrammaticallyMovingItem = false
  fileprivate var interactiveMovementMode = InteractiveMovementMode.noMovement
  
  
  // MARK: - NSFetchedResultsControllerDelegate
  
  public func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
    changes = []
    hadError = false
  }
  
  public func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange sectionInfo: NSFetchedResultsSectionInfo, atSectionIndex sectionIndex: Int, for type: NSFetchedResultsChangeType) {
    switch type {
    case .insert:
      changes.append(.sectionInsert(sectionIndex))
      
    case .delete:
      changes.append(.sectionDelete(sectionIndex))
      
    case .update, .move:
      break
      
    @unknown default:
      break
    }
  }
  
  public func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
    switch type {
    case .insert:
      guard let newIndexPath = newIndexPath else {
        hadError = true
        assertionFailure()
        break
      }
      
      changes.append(.objectInsert(newIndexPath))
      
    case .delete:
      guard let indexPath = indexPath else {
        hadError = true
        assertionFailure()
        break
      }
      
      changes.append(.objectDelete(indexPath))
      
    case .update:
      guard let indexPath = indexPath else {
        hadError = true
        assertionFailure()
        break
      }
      
      changes.append(.objectUpdate(indexPath))
      
    case .move:
      guard let indexPath = indexPath, let newIndexPath = newIndexPath else {
        hadError = true
        assertionFailure()
        break
      }
      
      changes.append(.objectMove(indexPath, newIndexPath))
      
    @unknown default:
      assertionFailure()
    }
  }
  
  public func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
    guard !changes.isEmpty else { return } // Nothing to do.
    // Data is changing because the collection view is requesting it. Because
    // the collection view already knows of the changes, we don't need to do
    // anything.
    guard !isProgrammaticallyMovingItem else { return }
    
    defer { delegate?.fetchedResultsControllerCollectionViewDataSourceDidUpdateContent(self) }
    
    guard !hadError else {
      // Can't trust the changes.
      collectionView?.reloadData()
      return
    }
    
    TryCatcher.try({ [unowned self] in
      self.collectionView?.performBatchUpdates({
        let changes = self.changes
        
        for change in changes {
          switch change {
          case let .sectionInsert(section):
            self.collectionView?.insertSections(IndexSet(integer: section))
            
          case let .sectionDelete(section):
            self.collectionView?.deleteSections(IndexSet(integer: section))
            
          case let .objectInsert(indexPath):
            self.collectionView?.insertItems(at: [indexPath])
            
          case let .objectDelete(indexPath):
            self.collectionView?.deleteItems(at: [indexPath])
            
          case let .objectUpdate(indexPath):
            guard let cell = self.collectionView?.cellForItem(at: indexPath) as? CellType else {
              break
            }
            
            let item = self.object(at: indexPath)
            self.delegate?.fetchedResultsControllerCollectionViewDataSource(self, configureCell: cell, forItem: item, atIndexPath: indexPath)
            
          case let .objectMove(from, to):
            // The item is moving because some data changed. Update the cell before
            // moving it.
            if let cell = self.collectionView?.cellForItem(at: from) as? CellType {
              // Use "to" since the object in "from" cell is already at the "to"
              // path in the data model.
              let item = self.object(at: to)
              self.delegate?.fetchedResultsControllerCollectionViewDataSource(self, configureCell: cell, forItem: item, atIndexPath: from)
            }
            
            self.collectionView?.moveItem(at: from, to: to)
          }
        }
      }, completion: nil)
    }) { [unowned self] _ in
      // An error occurred while performing the changes. The best we can do
      // is reload the collection view and hope it works.
      self.collectionView?.reloadData()
    }
  }
  
  
  // MARK: - UICollectionViewDataSource
  
  public func numberOfSections(in collectionView: UICollectionView) -> Int {
    return controller.sections?.count ?? 0
  }
  
  public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    let sectionInfo = controller.sections?[section]
    return sectionInfo?.numberOfObjects ?? 0
  }
  
  public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    let cell = collectionView.dequeueCell(for: indexPath) as CellType
    
    let itemIndexPath: IndexPath
    switch interactiveMovementMode {
    case .noMovement:
      itemIndexPath = IndexPath(item: (indexPath as NSIndexPath).item, section: (indexPath as NSIndexPath).section)
      
    case let .movement(movingIndexPath):
      var item = (indexPath as NSIndexPath).item
      
      if movingIndexPath == indexPath {
        // There is a bug that occurs when moving an item. When reproduced,
        // the collection view asks the data source for the moving item's cell
        // when it really needs to ask for the item that immediately preceeds
        // the moving item. This can be reproduced by moving the item far enough
        // that the collection view scrolls to a position where the moving 
        // item's original position is off screen. Then scroll back to the
        // original location. The cell that was positioned right before the
        // moving cell should look like the cell that is moving.
        item -= 1
      }
      
      itemIndexPath = IndexPath(item: item, section: (indexPath as NSIndexPath).section)
    }
    
    let item = object(at: itemIndexPath)
    delegate?.fetchedResultsControllerCollectionViewDataSource(self, configureCell: cell, forItem: item, atIndexPath: itemIndexPath)
    
    return cell
  }
  
  public func collectionView(_ collectionView: UICollectionView, canMoveItemAt indexPath: IndexPath) -> Bool {
    guard let delegate = delegate else { return true }
    return delegate.fetchedResultsControllerCollectionViewDataSource(self, canMoveItemAt: indexPath)
  }
  
  public func collectionView(_ collectionView: UICollectionView, moveItemAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
    isProgrammaticallyMovingItem = true
    delegate?.fetchedResultsControllerCollectionViewDataSource(self, moveItemAtIndexPath: sourceIndexPath, toIndexPath: destinationIndexPath)
    isProgrammaticallyMovingItem = false
  }
  
  public func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
    guard let view = delegate?.fetchedResultsControllerCollectionViewDataSource(self, collectionView: collectionView, viewForSupplementaryElementOfKind: kind, at: indexPath) else {
      return collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: kind, for: indexPath)
    }
    
    return view
  }
  
}
