//
//  MIT License
//
//  String+FlintKit.swift
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


private class Dummy {}
private let bundle: Bundle = {
  let frameworkBundle = Bundle(for: Dummy.self)
  
  guard
    let resourceBundleURL = frameworkBundle.url(forResource: "FlintKit", withExtension: "bundle"),
    let resourceBundle = Bundle(url: resourceBundleURL) else {
      assertionFailure("Could not find resource bundle.")
      return frameworkBundle
  }
  
  return resourceBundle
}()


extension String {
  
  // MARK: - Public Properties
  
  // MARK: C
  
  public static var cancel: String {
    return NSLocalizedString("Cancel", tableName: "FlintKitLocalizable", bundle: bundle, comment: "Cancel button on alert view")
  }
  
  public static var couldNotLaunchApp: String {
    guard let appName = Bundle.main.localizedAppName else {
      return NSLocalizedString("Could Not Launch App", tableName: "FlintKitLocalizable", bundle: bundle, comment: "title of alert that is shown when there was an error launching the app")
    }
    
    let format = NSLocalizedString("Could Not Launch %@", tableName: "FlintKitLocalizable", bundle: bundle, comment: "title of alert that is shown when there was an error launching the app; %@ is replaced with the app's name")
    return String(format: format, appName)
  }
  
  
  // MARK: D
  
  public static var done: String {
    return NSLocalizedString("Done", tableName: "FlintKitLocalizable", bundle: bundle, comment: "Done button on alert view")
  }
  
  
  // MARK: O
  
  public static var ok: String {
    return NSLocalizedString("OK", tableName: "FlintKitLocalizable", bundle: bundle, comment: "OK button on alert view")
  }
  
  
  // MARK: - T
  
  public static var theAppWillNowQuit: String {
    guard let appName = Bundle.main.localizedAppName else {
      return NSLocalizedString("The app will now quit.", tableName: "FlintKitLocalizable", bundle: bundle, comment: "message of error alert when the appe could not be loaded.")
    }
    
    let format = NSLocalizedString("%@ will now quit.", tableName: "FlintKitLocalizable", bundle: bundle, comment: "message of error alert when the app could not be loaded; %@ is replaced with the app's name")
    return String(format: format, appName)
  }
  
  
  // MARK: - Public Methods
  
  public func normalized() -> String {
    let mutable = NSMutableString(string: self) as CFMutableString
    // Using a trick to perform several transformations in one go. If this ever breaks,
    // these are the transformations that will need to be done one at a time:
    // - kCFStringTransformToLatin
    // - kCFStringTransformStripCombiningMarks
    // - kCFStringLowercase
    CFStringTransform(mutable, nil, "Any-Latin; Latin-ASCII; Any-Lower" as CFString, false)
    return mutable as String
  }
  
  
  // MARK: - Internal Methods
  
  /// Author: https://oleb.net/blog/2017/03/dump-as-equatable-safeguard/
  init<T>(dumping x: T) {
    self.init()
    dump(x, to: &self)
  }
  
}
