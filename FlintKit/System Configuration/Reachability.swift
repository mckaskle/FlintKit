//
//  MIT License
//
//  Reachability.swift
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
//  NOTE: Heavily influenced by https://github.com/ashleymills/Reachability.swift
//


import Foundation
import SystemConfiguration


extension Notification.Name {
  public static let reachabilityChanged = Notification.Name("reachabilityChanged")
}


private func callback(reachability: SCNetworkReachability, flags: SCNetworkReachabilityFlags, info: UnsafeMutableRawPointer?) {
  guard let info = info else { return }
  
  let reachability = Unmanaged<Reachability>.fromOpaque(info).takeUnretainedValue()
  reachability.reachabilityChanged(flags: flags)
}


public class Reachability {
  
  // MARK: - Enum
  
  public enum Connection {
    case none, wifi, cellular
  }
  
  public enum ReachabilityError: Error {
    case failedToCreateWithAddress(sockaddr)
    case failedToCreateWithHostname(String)
    case unableToSetCallback
    case unableToSetDispatchQueue
  }
  
  
  // MARK: - Type Alias
  
  public typealias Handler = (Reachability) -> ()
  
  
  // MARK: - Object Lifecycle
  
  required public init(reachabilityRef: SCNetworkReachability, handler: Handler? = nil) {
    self.reachabilityRef = reachabilityRef
    self.handler = handler
  }
  
  public convenience init(hostname: String, handler: Handler? = nil) throws {
    guard let ref = SCNetworkReachabilityCreateWithName(nil, hostname) else {
      throw ReachabilityError.failedToCreateWithHostname(hostname)
    }
    
    self.init(reachabilityRef: ref, handler: handler)
  }
  
  public convenience init(handler: Handler? = nil) throws {
    var zeroAddress = sockaddr()
    zeroAddress.sa_len = UInt8(MemoryLayout<sockaddr>.size)
    zeroAddress.sa_family = sa_family_t(AF_INET)
    
    guard let ref = SCNetworkReachabilityCreateWithAddress(nil, &zeroAddress) else {
      throw ReachabilityError.failedToCreateWithAddress(zeroAddress)
    }
    
    self.init(reachabilityRef: ref, handler: handler)
  }
  
  deinit {
    stopNotifier()
  }
  
  
  // MARK: - Public Properties
  
  /// Called when the Reachability status changes.
  public var handler: Handler?
  
  /// The notification center on which "reachability changed" events are being posted
  public var notificationCenter: NotificationCenter = .default
  
  public var connection: Connection {
    var flags = SCNetworkReachabilityFlags()
    guard SCNetworkReachabilityGetFlags(reachabilityRef, &flags) else { return .none }
    guard flags.contains(.reachable) else { return .none }
    
    // If we're reachable, but not on an iOS device (i.e. simulator), we must be on WiFi
    guard isRunningOnIOSDevice() else { return .wifi }
    
    var connection: Connection = .none
    
    if !flags.contains(.connectionRequired) {
      connection = .wifi
    }
    
    if !flags.intersection([.connectionOnTraffic, .connectionOnDemand]).isEmpty, !flags.contains(.interventionRequired) {
      connection = .wifi
    }
    
    #if os(iOS)
    if flags.contains(.isWWAN) {
      connection = .cellular
    }
    #endif
    
    return connection
  }
  
  
  // MARK: - Public Methods
  
  public func startNotifier() throws {
    guard !notifierRunning else { return }
    
    var context = SCNetworkReachabilityContext(version: 0, info: nil, retain: nil, release: nil, copyDescription: nil)
    context.info = UnsafeMutableRawPointer(Unmanaged<Reachability>.passUnretained(self).toOpaque())
    if !SCNetworkReachabilitySetCallback(reachabilityRef, callback, &context) {
      stopNotifier()
      throw ReachabilityError.unableToSetCallback
    }
    
    if !SCNetworkReachabilitySetDispatchQueue(reachabilityRef, reachabilitySerialQueue) {
      stopNotifier()
      throw ReachabilityError.unableToSetDispatchQueue
    }
    
    notifierRunning = true
  }
  
  public func stopNotifier() {
    defer { notifierRunning = false }
    
    SCNetworkReachabilitySetCallback(reachabilityRef, nil, nil)
    SCNetworkReachabilitySetDispatchQueue(reachabilityRef, nil)
  }
  
  
  // MARK: - Private Properties
  
  private var previousFlags: SCNetworkReachabilityFlags?
  
  private var notifierRunning = false
  private let reachabilityRef: SCNetworkReachability
  
  private let reachabilitySerialQueue = DispatchQueue(label: "com.flintkit.system-configuration.reachability")
  
  
  // MARK: - Private Methods
  
  private func isRunningOnIOSDevice() -> Bool {
    #if (arch(i386) || arch(x86_64)) && os(iOS)
      return false
    #else
      return true
    #endif
  }
  
  fileprivate func reachabilityChanged(flags: SCNetworkReachabilityFlags) {
    guard previousFlags != flags else { return }
    
    DispatchQueue.main.async {
      self.handler?(self)
      self.notificationCenter.post(name: .reachabilityChanged, object: self)
    }
    
    previousFlags = flags
  }
  
}
