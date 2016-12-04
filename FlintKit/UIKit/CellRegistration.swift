//
//  MIT License
//
//  CellRegistration.swift
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

import Foundation
import UIKit


// Adapted from:
// https://medium.com/@gonzalezreal/ios-cell-registration-reusing-with-swift-protocol-extensions-and-generics-c5ac4fb5b75e#.me93xp4ki


public protocol ReusableView: class {
  static var reuseIdentifier: String { get }
}

public extension ReusableView where Self: UIView {
  static var reuseIdentifier: String {
    return String(describing: self)
  }
}


extension UICollectionReusableView: ReusableView {}
extension UITableViewCell: ReusableView {}


public protocol ReusableSupplementaryView: ReusableView {
  static var supplementaryViewKind: String { get }
}


public extension UICollectionView {
  
  func register<T: UICollectionViewCell>(_: T.Type) where T: ReusableView {
    register(T.self, forCellWithReuseIdentifier: T.reuseIdentifier)
  }
  
  func register<T: UICollectionReusableView>(_: T.Type) where T: ReusableSupplementaryView {
    register(T.self, forSupplementaryViewOfKind: T.supplementaryViewKind, withReuseIdentifier: T.reuseIdentifier)
  }
  
  func register<T: UICollectionViewCell>(_: T.Type) where T: ReusableView, T:NibLoadableView {
    let bundle = Bundle(for: T.self)
    let nib = UINib(nibName: T.nibName, bundle: bundle)
    register(nib, forCellWithReuseIdentifier: T.reuseIdentifier)
  }
  
  func register<T: UICollectionReusableView>(_: T.Type) where T: ReusableSupplementaryView, T:NibLoadableView {
    let bundle = Bundle(for: T.self)
    let nib = UINib(nibName: T.nibName, bundle: bundle)
    register(nib, forSupplementaryViewOfKind: T.supplementaryViewKind, withReuseIdentifier: T.reuseIdentifier)
  }
  
  func dequeueCell<T: UICollectionViewCell>(for indexPath: IndexPath) -> T where T: ReusableView {
    guard let cell = dequeueReusableCell(withReuseIdentifier: T.reuseIdentifier, for: indexPath) as? T else {
      fatalError()
    }
    
    return cell
  }
  
  func dequeueSupplementaryView<T: UICollectionReusableView>(for indexPath: IndexPath) -> T where T: ReusableSupplementaryView {
    guard let view = dequeueReusableSupplementaryView(ofKind: T.supplementaryViewKind, withReuseIdentifier: T.reuseIdentifier, for: indexPath) as? T else {
      fatalError()
    }
    
    return view
  }
  
}

public extension UITableView {
  
  func register<T: UITableViewCell>(_: T.Type) where T: ReusableView {
    self.register(T.self, forCellReuseIdentifier: T.reuseIdentifier)
  }
  
  func register<T: UITableViewCell>(_: T.Type) where T: ReusableView, T:NibLoadableView {
    let bundle = Bundle(for: T.self)
    let nib = UINib(nibName: T.nibName, bundle: bundle)
    self.register(nib, forCellReuseIdentifier: T.reuseIdentifier)
  }
  
  func dequeueCell<T: UITableViewCell>(for indexPath: IndexPath) -> T where T: ReusableView {
    guard let cell = dequeueReusableCell(withIdentifier: T.reuseIdentifier, for: indexPath) as? T else {
      fatalError()
    }
    
    return cell
  }
  
}
