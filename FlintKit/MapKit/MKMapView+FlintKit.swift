//
//  MIT License
//
//  MKMapView+FlintKit.swift
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
import MapKit


public protocol ReusableAnnotationView: class {
  static var reuseIdentifier: String { get }
}


@available(tvOS 9.2, *)
public extension ReusableAnnotationView where Self: MKAnnotationView {
  static var reuseIdentifier: String {
    return String(describing: self)
  }
}


@available(tvOS 9.2, *)
extension MKAnnotationView: ReusableAnnotationView {}


@available(tvOS 9.2, *)
public extension MKMapView {
  
  func dequeueAnnotationView<T: MKAnnotationView>(for annotation: MKAnnotation) -> T {
    if let view = dequeueReusableAnnotationView(withIdentifier: T.reuseIdentifier) as? T {
      view.annotation = annotation
      return view
    }
    
    return T(annotation: annotation, reuseIdentifier: T.reuseIdentifier)
  }
  
}
