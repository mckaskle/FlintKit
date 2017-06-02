//
//  MIT License
//
//  Keychain.swift
//
//  Copyright (c) 2016 Devin McKaskle
//
//  Modified from https://github.com/jrendel/SwiftKeychainWrapper
//  Copyright © 2016 Jason Rendel. All rights reserved.
//
//    The MIT License (MIT)
//
//    Permission is hereby granted, free of charge, to any person obtaining a copy
//    of this software and associated documentation files (the "Software"), to deal
//    in the Software without restriction, including without limitation the rights
//    to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//    copies of the Software, and to permit persons to whom the Software is
//    furnished to do so, subject to the following conditions:
//
//    The above copyright notice and this permission notice shall be included in all
//    copies or substantial portions of the Software.
//
//    THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//    IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//    FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//    AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//    LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//    OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//    SOFTWARE.


import Foundation
import Security


private let SecAttrAccessGroup = kSecAttrAccessGroup as String
private let SecAttrAccessible = kSecAttrAccessible as String
private let SecAttrAccount = kSecAttrAccount as String
private let SecAttrGeneric = kSecAttrGeneric as String
private let SecAttrService = kSecAttrService as String
private let SecClass = kSecClass as String
private let SecMatchLimit = kSecMatchLimit as String
private let SecReturnData = kSecReturnData as String
private let SecValueData = kSecValueData as String


final public class Keychain {
  
  // MARK: - Enum
  
  public enum Accessibility {
    /**
     The data in the keychain item cannot be accessed after a restart until the 
     device has been unlocked once by the user.
     
     After the first unlock, the data remains accessible until the next restart. 
     This is recommended for items that need to be accessed by background
     applications. Items with this attribute migrate to a new device when using
     encrypted backups.
     */
    @available(iOS 4, *)
    case afterFirstUnlock
    
    /**
     The data in the keychain item cannot be accessed after a restart until the
     device has been unlocked once by the user.
     
     After the first unlock, the data remains accessible until the next restart. 
     This is recommended for items that need to be accessed by background 
     applications. Items with this attribute do not migrate to a new device. 
     Thus, after restoring from a backup of a different device, these items will
     not be present.
     */
    @available(iOS 4, *)
    case afterFirstUnlockThisDeviceOnly
    
    /**
     The data in the keychain item can always be accessed regardless of whether
     the device is locked.
     
     This is not recommended for application use. Items with this attribute
     migrate to a new device when using encrypted backups.
     */
    @available(iOS 4, *)
    case always
    
    /**
     The data in the keychain can only be accessed when the device is unlocked. 
     Only available if a passcode is set on the device.
     
     This is recommended for items that only need to be accessible while the
     application is in the foreground. Items with this attribute never migrate 
     to a new device. After a backup is restored to a new device, these items
     are missing. No items can be stored in this class on devices without a
     passcode. Disabling the device passcode causes all items in this class to
     be deleted.
     */
    @available(iOS 8, *)
    case whenPasscodeSetThisDeviceOnly
    
    /**
     The data in the keychain item can always be accessed regardless of whether 
     the device is locked.
     
     This is not recommended for application use. Items with this attribute do
     not migrate to a new device. Thus, after restoring from a backup of a
     different device, these items will not be present.
     */
    @available(iOS 4, *)
    case alwaysThisDeviceOnly
    
    /**
     The data in the keychain item can be accessed only while the device is
     unlocked by the user.
     
     This is recommended for items that need to be accessible only while the
     application is in the foreground. Items with this attribute migrate to a 
     new device when using encrypted backups.
     
     This is the default value for keychain items added without explicitly
     setting an accessibility constant.
     */
    @available(iOS 4, *)
    case whenUnlocked
    
    /**
     The data in the keychain item can be accessed only while the device is
     unlocked by the user.
     
     This is recommended for items that need to be accessible only while the
     application is in the foreground. Items with this attribute do not migrate 
     to a new device. Thus, after restoring from a backup of a different device, 
     these items will not be present.
     */
    @available(iOS 4, *)
    case whenUnlockedThisDeviceOnly
    
    
    public static var `default`: Accessibility { return .whenUnlocked }
    
    
    fileprivate var keychainAttrValue: CFString {
      switch self {
        case .afterFirstUnlock: return kSecAttrAccessibleAfterFirstUnlock
        case .afterFirstUnlockThisDeviceOnly: return kSecAttrAccessibleAfterFirstUnlockThisDeviceOnly
        case .always: return kSecAttrAccessibleAlways
        case .whenPasscodeSetThisDeviceOnly: return kSecAttrAccessibleWhenPasscodeSetThisDeviceOnly
        case .alwaysThisDeviceOnly : return kSecAttrAccessibleAlwaysThisDeviceOnly
        case .whenUnlocked: return kSecAttrAccessibleWhenUnlocked
        case .whenUnlockedThisDeviceOnly: return kSecAttrAccessibleWhenUnlockedThisDeviceOnly
      }
    }
    
  }
  
  public enum Error: Swift.Error {
    case didNotReceiveItemAsData
    case couldNotDecodeObject
    case couldNotDecodeString
    case couldNotEncodeString
    case couldNotEncodeKey
    case couldNotCreateKeychainItem(OSStatus)
    case couldNotDeleteKeychainItem(OSStatus)
    case couldNotDeleteKeychainService(OSStatus)
    case couldNotUpdateKeychainItem(OSStatus)
  }
  
  
  // MARK: - Object Lifecycle
  
  /// Create a custom instance of Keychain with a custom Service Name and optional
  /// custom access group.
  ///
  /// - parameter serviceName: The ServiceName for this instance. Used to uniquely
  ///   identify all keys stored using this keychain wrapper instance.
  /// - parameter accessGroup: Optional unique AccessGroup for this instance. Use a
  ///   matching AccessGroup between applications to allow shared keychain access.
  public init(serviceName: String, accessGroup: String? = nil) {
    self.serviceName = serviceName
    self.accessGroup = accessGroup
  }
  
  
  // MARK: - Public Methods
  
  // MARK: Getters
  
  /// Returns an Int value for a specified key.
  ///
  /// - parameter forKey: The key to lookup data for.
  /// - parameter accessibility: Optional accessibility to use when retrieving
  ///   the keychain item.
  /// - returns: The Int associated with the key if it exists. If no data
  ///   exists, returns nil.
  /// - throws: If the Int data cannot be decoded, an error is thrown.
  public func integer(forKey key: String, accessibility: Accessibility? = nil) throws -> Int? {
    return try number(forKey: key, accessibility: accessibility)?.intValue
  }
  
  /// Returns an Float value for a specified key.
  ///
  /// - parameter forKey: The key to lookup data for.
  /// - parameter accessibility: Optional accessibility to use when retrieving
  ///   the keychain item.
  /// - returns: The Float associated with the key if it exists. If no data
  ///   exists, returns nil.
  /// - throws: If the Float data cannot be decoded, an error is thrown.
  public func float(forKey key: String, accessibility: Accessibility? = nil) throws -> Float? {
    return try number(forKey: key, accessibility: accessibility)?.floatValue
  }
  
  /// Returns an Double value for a specified key.
  ///
  /// - parameter forKey: The key to lookup data for.
  /// - parameter accessibility: Optional accessibility to use when retrieving
  ///   the keychain item.
  /// - returns: The Double associated with the key if it exists. If no data
  ///   exists, returns nil.
  /// - throws: If the Double data cannot be decoded, an error is thrown.
  public func double(forKey key: String, accessibility: Accessibility? = nil) throws -> Double? {
    return try number(forKey: key, accessibility: accessibility)?.doubleValue
  }
  
  /// Returns an Bool value for a specified key.
  ///
  /// - parameter forKey: The key to lookup data for.
  /// - parameter accessibility: Optional accessibility to use when retrieving
  ///   the keychain item.
  /// - returns: The Bool associated with the key if it exists. If no data
  ///   exists, returns nil.
  /// - throws: If the Bool data cannot be decoded, an error is thrown.
  public func bool(forKey key: String, accessibility: Accessibility? = nil) throws -> Bool? {
    return try number(forKey: key, accessibility: accessibility)?.boolValue
  }
  
  /// Returns a string value for a specified key.
  ///
  /// - parameter forKey: The key to lookup data for.
  /// - parameter accessibility: Optional accessibility to use when retrieving 
  ///   the keychain item.
  /// - returns: The String associated with the key if it exists. If no data
  ///   exists, returns nil.
  /// - throws: If the string data cannot be decoded, an error is thrown.
  public func string(forKey key: String, accessibility: Accessibility? = nil) throws -> String? {
    guard let data = try self.data(forKey: key, accessibility: accessibility) else { return nil }
    guard let string = String(data: data, encoding: .utf8) else { throw Error.couldNotDecodeString }
    return string
  }
  
  /// Returns an object that conforms to NSCoding for a specified key.
  ///
  /// - parameter forKey: The key to lookup data for.
  /// - parameter accessibility: Optional accessibility to use when retrieving 
  ///   the keychain item.
  /// - returns: The decoded object associated with the key if it exists. If no
  ///   data exists, returns nil.
  /// - throws: If the data cannot be decoded, an error is thrown.
  public func object<T: NSCoding>(forKey key: String, accessibility: Accessibility? = nil) throws -> T? {
    guard let data = try self.data(forKey: key, accessibility: accessibility) else { return nil }
    guard let object = NSKeyedUnarchiver.unarchiveObject(with: data) as? T else { throw Error.couldNotDecodeObject }
    return object
  }
  
  
  /// Returns a Data object for a specified key.
  ///
  /// - parameter forKey: The key to lookup data for.
  /// - parameter accessibility: Optional accessibility to use when retrieving
  ///   the keychain item.
  /// - returns: The Data object associated with the key if it exists. If no 
  ///   data exists, returns nil.
  /// - throws: If the result of the keychain query is anything other than a 
  /// Data object, an error is thrown.
  public func data(forKey key: String, accessibility: Accessibility? = nil) throws -> Data? {
    var dictionary = try queryDictionary(forKey: key, accessibility: accessibility)
    var result: AnyObject?
    
    // Limit search results to one
    dictionary[SecMatchLimit] = kSecMatchLimitOne
    
    // Specify we want Data/CFData returned
    dictionary[SecReturnData] = kCFBooleanTrue
    
    // Search
    let status = withUnsafeMutablePointer(to: &result) {
      SecItemCopyMatching(dictionary as CFDictionary, UnsafeMutablePointer($0))
    }
    
    guard status != errSecItemNotFound else { return nil }
    guard let data = result as? Data else { throw Error.didNotReceiveItemAsData }
    return data
  }
  
  // MARK: Setters
  
  public func set(_ value: Int, forKey key: String, accessibility: Accessibility = .default) throws {
    try set(NSNumber(value: value), forKey: key, accessibility: accessibility)
  }
  
  public func set(_ value: Float, forKey key: String, accessibility: Accessibility = .default) throws {
    try set(NSNumber(value: value), forKey: key, accessibility: accessibility)
  }
  
  public func set(_ value: Double, forKey key: String, accessibility: Accessibility = .default) throws {
    try set(NSNumber(value: value), forKey: key, accessibility: accessibility)
  }
  
  public func set(_ value: Bool, forKey key: String, accessibility: Accessibility = .default) throws {
    try set(NSNumber(value: value), forKey: key, accessibility: accessibility)
  }
  
  /// Save a String value to the keychain associated with a specified key. If a 
  /// String value already exists for the given key, the string will be 
  /// overwritten with the new value.
  ///
  /// - parameter value: The String value to save.
  /// - parameter forKey: The key to save the String under.
  /// - parameter accessibility: accessibility to use when setting the keychain 
  ///   item.
  /// - throws: Throws an error if the save failed.
  public func set(_ value: String, forKey key: String, accessibility: Accessibility = .default) throws {
    guard let data = value.data(using: .utf8, allowLossyConversion: false) else { throw Error.couldNotEncodeString }
    try set(data, forKey: key, accessibility: accessibility)
  }
  
  /// Save an NSCoding compliant object to the keychain associated with a 
  /// specified key. If an object already exists for the given key, the object
  /// will be overwritten with the new value.
  ///
  /// - parameter value: The NSCoding compliant object to save.
  /// - parameter forKey: The key to save the object under.
  /// - parameter accessibility:  accessibility to use when setting the keychain
  ///   item.
  /// - throws: Throws an error if the save failed.
  public func set(_ value: NSCoding, forKey key: String, accessibility: Accessibility = .default) throws {
    let data = NSKeyedArchiver.archivedData(withRootObject: value)
    try set(data, forKey: key, accessibility: accessibility)
  }
  
  /// Save a Data object to the keychain associated with a specified key. If data
  /// already exists for the given key, the data will be overwritten with the new 
  /// value.
  ///
  /// - parameter value: The Data object to save.
  /// - parameter forKey: The key to save the object under.
  /// - parameter accessibility: accessibility to use when setting the keychain
  ///   item.
  /// - throws: Throws an error if the save failed.
  public func set(_ value: Data, forKey key: String, accessibility: Accessibility = .default) throws {
    var dictionary = try queryDictionary(forKey: key, accessibility: accessibility)
    dictionary[SecValueData] = value
    dictionary[SecAttrAccessible] = accessibility.keychainAttrValue
    
    let status = SecItemAdd(dictionary as CFDictionary, nil)
    
    if status == errSecDuplicateItem {
      try update(value, forKey: key, accessibility: accessibility)
      return
    }
    
    guard status == errSecSuccess else { throw Error.couldNotCreateKeychainItem(status) }
  }
  
  /// Remove an object associated with a specified key. If re-using a key but 
  /// with a different accessibility, first remove the previous key value using
  /// removeObject(forKey:accessibility:) using the same accessibilty it was 
  /// saved with.
  ///
  /// - parameter forKey: The key value to remove data for.
  /// - parameter accessibility: accessibility level to use when
  ///   looking up the keychain item.
  /// - throws: Throws an error if the item could not be deleted.
  public func removeItem(forKey key: String, accessibility: Accessibility = .default) throws {
    let dictionary = try queryDictionary(forKey: key, accessibility: accessibility)
    
    // Delete
    let status = SecItemDelete(dictionary as CFDictionary)
    guard status == errSecSuccess else { throw Error.couldNotDeleteKeychainItem(status) }
  }
  
  /// Remove all keychain data added through Keychain. This will only delete 
  /// items matching the currnt ServiceName and AccessGroup if one is set.
  ///
  /// - throws: Throws an error if the keychain service couldn't be deleted.
  public func removeAll() throws {
    // Setup dictionary to access keychain and specify we are using a generic 
    // password (rather than a certificate, internet password, etc)
    var dictionary: [String: Any] = [SecClass: kSecClassGenericPassword]
    
    // Uniquely identify this keychain accessor
    dictionary[SecAttrService] = serviceName
    
    // Set the keychain access group if defined
    if let accessGroup = accessGroup {
      dictionary[SecAttrAccessGroup] = accessGroup
    }
    
    let status = SecItemDelete(dictionary as CFDictionary)
    let validStatuses: Set<OSStatus> = [errSecSuccess, errSecItemNotFound]
    guard validStatuses.contains(status) else { throw Error.couldNotDeleteKeychainService(status) }
  }
  
  
  // MARK: - Private Properties
  
  /// ServiceName is used for the kSecAttrService property to uniquely identify
  /// this keychain accessor.
  private let serviceName: String
  
  /// AccessGroup is used for the kSecAttrAccessGroup property to identify which
  /// Keychain Access Group this entry belongs to. This allows you to use the
  /// KeychainWrapper with shared keychain access between different applications.
  private let accessGroup: String?
  
  
  // MARK: - Private Methods
  
  /// Setup the keychain query dictionary used to access the keychain on iOS for
  /// a specified key name. Takes into account the Service Name and Access Group 
  /// if one is set.
  ///
  /// - parameter forKey: The key this query is for
  /// - parameter accessibility: Optional accessibility to use when setting the 
  ///   keychain item. If none is provided, will default to .WhenUnlocked
  /// - returns: A dictionary with all the needed properties setup to access the 
  ///   keychain on iOS
  /// - throws: Throws an error when the key could not be encoded.
  private func queryDictionary(forKey key: String, accessibility: Accessibility?) throws -> [String: Any] {
    // Setup default access as generic password (rather than a certificate,
    // internet password, etc).
    var dictionary: [String: Any] = [SecClass: kSecClassGenericPassword]
    
    // Uniquely identify this keychain accessor.
    dictionary[SecAttrService] = serviceName
    
    // Only set accessibiilty if its passed in, we don't want to default it
    // here in case the user didn't want it set.
    if let accessibility = accessibility {
      dictionary[SecAttrAccessible] = accessibility.keychainAttrValue
    }
    
    // Set the keychain access group, if defined.
    if let accessGroup = accessGroup {
      dictionary[SecAttrAccessGroup] = accessGroup
    }
    
    // Uniquely identify the account who will be accessing the keychain
    guard let encodedIdentifier = key.data(using: .utf8) else { throw Error.couldNotEncodeKey }
    dictionary[SecAttrGeneric] = encodedIdentifier
    dictionary[SecAttrAccount] = encodedIdentifier
    
    return dictionary
  }
  
  /// Update existing data associated with a specified key name. The existing
  /// data will be overwritten by the new data.
  private func update(_ value: Data, forKey key: String, accessibility: Accessibility?) throws {
    let queryDictionary = try self.queryDictionary(forKey: key, accessibility: accessibility)
    let updateDictionary = [SecValueData: value]
    
    // Update
    let status = SecItemUpdate(queryDictionary as CFDictionary, updateDictionary as CFDictionary)
    guard status == errSecSuccess else { throw Error.couldNotUpdateKeychainItem(status) }
  }
  
  private func number(forKey key: String, accessibility: Accessibility?) throws -> NSNumber? {
    return try self.object(forKey: key, accessibility: accessibility)
  }
  
}
