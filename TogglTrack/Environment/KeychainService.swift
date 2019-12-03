//
//  KeychainService.swift
//  TogglWatch
//
//  Created by Juxhin Bakalli on 15/11/19.
//  Copyright © 2019 Toggl. All rights reserved.
//

import Security
import Foundation

public protocol KeychainProtocol
{
    func setApiToken(token: String)
    func getApiToken() -> String?
    func deleteApiToken()
}

public class Keychain
{
    open var lastResultCode: OSStatus = noErr
    
    open var accessGroup: String?
    open var synchronizable: Bool = false
    private let readLock = NSLock()
    
    public init() { }
    
    @discardableResult
    open func set(_ value: String, forKey key: String) -> Bool {
        
        if let value = value.data(using: String.Encoding.utf8) {
            return set(value, forKey: key)
        }
        
        return false
    }
    
    @discardableResult
    open func set(_ value: Data, forKey key: String) -> Bool {
        
        delete(key) // Delete any existing key before saving it
        
        let prefixedKey = key
        
        var query: [String : Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String : prefixedKey,
            kSecValueData as String: value,
            kSecAttrAccessible as String: kSecAttrAccessibleWhenUnlocked
        ]
        
        query = addAccessGroupWhenPresent(query)
        query = addSynchronizableIfRequired(query, addingItems: true)
        
        lastResultCode = SecItemAdd(query as CFDictionary, nil)
        
        return lastResultCode == noErr
    }
   
    open func get(_ key: String) -> String? {
        if let data = getData(key) {
            
            if let currentString = String(data: data, encoding: .utf8) {
                return currentString
            }
            
            lastResultCode = -67853 // errSecInvalidEncoding
        }
        
        return nil
    }
    
    open func getData(_ key: String) -> Data? {
        // The lock prevents the code to be run simlultaneously
        // from multiple threads which may result in crashing
        readLock.lock()
        defer { readLock.unlock() }
        
        let prefixedKey = key
        
        var query: [String: Any] = [
            kSecClass as String : kSecClassGenericPassword,
            kSecAttrAccount as String : prefixedKey,
            kSecReturnData as String : kCFBooleanTrue!,
            kSecMatchLimit as String : kSecMatchLimitOne
        ]
        
        query = addAccessGroupWhenPresent(query)
        query = addSynchronizableIfRequired(query, addingItems: false)
        
        var result: AnyObject?
        
        lastResultCode = withUnsafeMutablePointer(to: &result) {
            SecItemCopyMatching(query as CFDictionary, UnsafeMutablePointer($0))
        }
        
        if lastResultCode == noErr { return result as? Data }
        
        return nil
    }

    @discardableResult
    open func delete(_ key: String) -> Bool {
        let prefixedKey = key
        
        var query: [String: Any] = [
            kSecClass as String : kSecClassGenericPassword,
            kSecAttrAccount as String : prefixedKey
        ]
        
        query = addAccessGroupWhenPresent(query)
        query = addSynchronizableIfRequired(query, addingItems: false)
        
        lastResultCode = SecItemDelete(query as CFDictionary)
        
        return lastResultCode == noErr
    }
    
    @discardableResult
    open func clear() -> Bool {
        var query: [String: Any] = [ kSecClass as String : kSecClassGenericPassword ]
        query = addAccessGroupWhenPresent(query)
        query = addSynchronizableIfRequired(query, addingItems: false)
        
        lastResultCode = SecItemDelete(query as CFDictionary)
        
        return lastResultCode == noErr
    }
    
    func addAccessGroupWhenPresent(_ items: [String: Any]) -> [String: Any] {
        guard let accessGroup = accessGroup else { return items }
        
        var result: [String: Any] = items
        result[kSecAttrAccessGroup as String] = accessGroup
        return result
    }
    
    func addSynchronizableIfRequired(_ items: [String: Any], addingItems: Bool) -> [String: Any] {
        if !synchronizable { return items }
        var result: [String: Any] = items
        result[kSecAttrSynchronizable as String] = addingItems == true ? true : kSecAttrSynchronizableAny
        return result
    }
}

extension Keychain: KeychainProtocol
{
    public func setApiToken(token: String)
    {
        set(token, forKey: "apiToken")
    }
    
    public func getApiToken() -> String?
    {
        guard let token = get("apiToken") else { return nil }
        
        return token
    }
    
    public func deleteApiToken()
    {
        delete("apiToken")
    }
}
