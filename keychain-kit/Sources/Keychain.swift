//
//  Keychain.swift
//  keychain-kit
//
//  Created by Aleksey Zgurskiy on 02.02.2020.
//  Copyright © 2020 mr.noone. All rights reserved.
//

import Foundation

public struct Keychain {
  public enum Error: Swift.Error {
    case noData
    case unexpectedData
    case unexpected(code: OSStatus)
  }
  
  // MARK: - Inits
  
  public init() {}
  
  // MARK: - Public methods
  
  public func get(_ key: String) throws -> Data {
    let query: [CFString : AnyObject] = [
      kSecClass : kSecClassGenericPassword,
      kSecAttrAccount : key as AnyObject,
      kSecMatchLimit : kSecMatchLimitOne,
      kSecReturnData : kCFBooleanTrue
    ]
    
    var queryResult: AnyObject?
    let status = withUnsafeMutablePointer(to: &queryResult) {
      SecItemCopyMatching(query as CFDictionary, UnsafeMutablePointer($0))
    }
    
    guard status != errSecItemNotFound else { throw Error.noData }
    guard status == noErr else { throw Error.unexpected(code: status) }
    
    guard
      let item = queryResult as? [CFString : AnyObject],
      let data = item[kSecValueData] as? Data
    else { throw Error.noData }
    
    return data
  }
  
  public func get(_ key: String) throws -> String {
    guard let value = String(data: try get(key), encoding: .utf8) else {
      throw Error.unexpectedData
    }
    return value
  }
  
  public func get(_ key: String) throws -> UUID {
    guard let value = UUID(uuidString: try get(key)) else {
      throw Error.unexpectedData
    }
    return value
  }
  
  public func get<T>(_ key: String, decoder: JSONDecoder = JSONDecoder()) throws -> T where T: Decodable {
    return try decoder.decode(T.self, from: get(key))
  }
  
  public func set(_ data: Data, for key: String) throws {
    try delete(key)
    
    let query: [CFString : AnyObject] = [
      kSecClass : kSecClassGenericPassword,
      kSecAttrAccount : key as AnyObject,
      kSecValueData : data as AnyObject
    ]
    
    let status = SecItemAdd(query as CFDictionary, nil)
    guard status == noErr else { throw Error.unexpected(code: status) }
  }
  
  public func set(_ value: String, for key: String) throws {
    try set(value.data(using: .utf8)!, for: key)
  }
  
  public func set(_ uuid: UUID, for key: String) throws {
    try set(uuid.uuidString, for: key)
  }
  
  public func set<T>(_ value: T, for key: String, encoder: JSONEncoder = JSONEncoder()) throws where T: Encodable {
    try set(encoder.encode(value), for: key)
  }
  
  public func delete(_ key: String) throws {
    let query: [CFString : AnyObject] = [
      kSecClass : kSecClassGenericPassword,
      kSecAttrAccount : key as AnyObject
    ]
    
    let status = SecItemDelete(query as CFDictionary)
    guard status == noErr  || status == errSecItemNotFound else {
      throw Error.unexpected(code: status)
    }
  }
}
