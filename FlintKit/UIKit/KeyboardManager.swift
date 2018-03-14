//
//  MIT License
//
//  KeyboardManager.swift
//
//  Copyright (c) 2018 Devin McKaskle
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


public final class KeyboardManager {
  
  // MARK: - Type Aliases
  
  public typealias Handler = (Context) -> Void
  
  
  // MARK: - Subtypes
  
  public struct Context {
    
    // MARK: - Object Lifecycle
    
    fileprivate init(notification: Notification) {
      animationDuration = notification.keyboardAnimationDuration
      animationOptions = notification.keyboardAnimationOptions
      frameBegin = notification.keyboardFrameBegin
      frameEnd = notification.keyboardFrameEnd
    }
    
    
    // MARK: - Public Properties
    
    public let animationDuration: TimeInterval?
    public let animationOptions: UIViewAnimationOptions
    /// `CGRect` that identifies the start frame of the keyboard in screen
    /// coordinates. These coordinates do not take into account any rotation
    /// factors applied to the view’s contents as a result of interface
    /// orientation changes. Thus, you may need to convert the rectangle to view
    /// coordinates (using the `convert(CGRect, from: UIView?)` method) before
    /// using it.
    ///
    /// See also: `convertedFrameBegin(in: UIView)`.
    public let frameBegin: CGRect?
    /// `CGRect` that identifies the end frame of the keyboard in screen
    /// coordinates. These coordinates do not take into account any rotation
    /// factors applied to the view’s contents as a result of interface
    /// orientation changes. Thus, you may need to convert the rectangle to view
    /// coordinates (using the `convert(CGRect, from: UIView?)` method) before
    /// using it.
    ///
    /// See also: `convertedFrameEnd(in: UIView)`.
    public let frameEnd: CGRect?
    
    
    // MARK: - Public Methods
    
    /// Convenience method that returns the begining frame of the keyboard that
    /// has already been converted into the given view's coordinate space.
    public func convertedFrameBegin(in view: UIView) -> CGRect? {
      return frameBegin.map { view.convert($0, from: view.window) }
    }
    
    /// Convenience method that returns the ending frame of the keyboard that
    /// has already been converted into the given view's coordinate space.
    public func convertedFrameEnd(in view: UIView) -> CGRect? {
      return frameEnd.map { view.convert($0, from: view.window) }
    }
    
  }
  
  
  // MARK: - Object Lifecycle
  
  public init() {
    NotificationCenter.default.addObserver(
      self,
      selector: #selector(keyboardWillHide(_:)),
      name: .UIKeyboardWillHide,
      object: nil
    )
    NotificationCenter.default.addObserver(
      self,
      selector: #selector(keyboardWillShow(_:)),
      name: .UIKeyboardWillShow,
      object: nil
    )
  }
  
  
  // MARK: - Public Properties
  
  /// This handler will be called within an animation block that matches the
  /// animation timing of the keyboard being shown.
  public var keyboardWillShowHandler: Handler?
  /// This handler will be called within an animation block that matches the
  /// animation timing of the keyboard being hidden.
  public var keyboardWillHideHandler: Handler?
  
  
  // MARK: - Public Methods
  
  public func startAutoAdjustingContentInsets(for scrollView: UIScrollView) {
    scrollViews.insert(scrollView)
  }
  
  public func stopAutoAdjustingContentInsets(for scrollView: UIScrollView) {
    scrollViews.remove(scrollView)
  }
  
  
  // MARK: - Private Methods
  
  private var scrollViews: Set<UIScrollView> = []
  
  
  // MARK: - Actions
  
  @objc dynamic private func keyboardWillShow(_ notification: Notification) {
    let context = Context(notification: notification)
    let duration = context.animationDuration ?? 0.3

    UIView.animate(withDuration: duration, delay: 0, options: context.animationOptions, animations: {
      for scrollView in self.scrollViews {
        guard var frame = context.convertedFrameEnd(in: scrollView) else { continue }
        
        if #available(iOS 11.0, *) {
          frame = frame.inset(by: scrollView.safeAreaInsets)
        }
        
        let heightOverlappingScrollView = scrollView.bounds.intersection(frame).height
        
        scrollView.contentInset.bottom = heightOverlappingScrollView
        scrollView.scrollIndicatorInsets.bottom = heightOverlappingScrollView
      }
      
      self.keyboardWillShowHandler?(context)
    }, completion: nil)
  }
  
  @objc dynamic private func keyboardWillHide(_ notification: Notification) {
    let context = Context(notification: notification)
    let duration = context.animationDuration ?? 0.3
    UIView.animate(withDuration: duration, delay: 0, options: context.animationOptions, animations: {
      for scrollView in self.scrollViews {
        scrollView.contentInset.bottom = 0
        scrollView.scrollIndicatorInsets.bottom = 0
      }
      
      self.keyboardWillHideHandler?(context)
    }, completion: nil)
  }
  
}
