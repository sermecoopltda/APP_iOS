//
//  SessionModel.swift
//  Reembolsos
//
//  Created by Carlos Oliva on 3/14/19.
//  Copyright © 2019 Sermecoop. All rights reserved.
//

import Foundation
import KeychainSwift

public struct SessionModel {
    private struct statics {
        static let tokenKeychainKey = "userTokenKeychainKey"
        static let usernameKeychainKey = "usernameKeychainKey"
        static let passwordKeychainKey = "passwordKeychainKey"
    }

    private init() { }

    public static var current: SessionModel? {
        let keychain = KeychainSwift()
        guard keychain.get(statics.tokenKeychainKey) != nil, keychain.get(statics.usernameKeychainKey) != nil, keychain.get(statics.passwordKeychainKey) != nil else { return nil }
        return SessionModel()
    }

    public var token: String {
        get {
            let keychain = KeychainSwift()
            return keychain.get(statics.tokenKeychainKey) ?? ""
        }

        set {
            let keychain = KeychainSwift()
            keychain.set(newValue, forKey: statics.tokenKeychainKey)
        }
    }

    public var username: String {
        let keychain = KeychainSwift()
        return keychain.get(statics.usernameKeychainKey) ?? ""
    }

    public var password: String {
        let keychain = KeychainSwift()
        return keychain.get(statics.passwordKeychainKey) ?? ""
    }

    public static func setCurrent(token: String, username: String, password: String) {
        let keychain = KeychainSwift()
        keychain.set(token, forKey: statics.tokenKeychainKey)
        keychain.set(username, forKey: statics.usernameKeychainKey)
        keychain.set(password, forKey: statics.passwordKeychainKey)
    }

    public static func signOut() {
        let keychain = KeychainSwift()
        keychain.delete(statics.tokenKeychainKey)
        keychain.delete(statics.usernameKeychainKey)
        keychain.delete(statics.passwordKeychainKey)
    }
}
