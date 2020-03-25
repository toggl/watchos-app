//
//  AppEnvironment.swift
//  TogglWatch WatchKit Extension
//
//  Created by Ricardo Sánchez Sotres on 06/11/2019.
//  Copyright © 2019 Toggl. All rights reserved.
//

import Foundation

public struct AppEnvironment
{

    public let api: APIProtocol
    public let firebaseAPI: FirebaseAPIProtocol
    public let keychain: KeychainProtocol
    public let dateService: DateServiceProtocol
    public let pushTokenStorage: PushTokenStorageProtocol
    public let signInWithAppleService: SignInWithAppleServiceProtocol
    
    public init(api: APIProtocol, firebaseAPI: FirebaseAPIProtocol, keychain: KeychainProtocol, dateService: DateServiceProtocol, pushTokenStorage: PushTokenStorageProtocol, signInWithApple: SignInWithAppleServiceProtocol)
    {
        self.api = api
        self.firebaseAPI = firebaseAPI
        self.keychain = keychain
        self.dateService = dateService
        self.pushTokenStorage = pushTokenStorage
        self.signInWithAppleService = signInWithApple
    }
}

// Sub-environments
extension AppEnvironment
{
    public var loginEnvironment: LoginEnvironment { (api, keychain, pushTokenStorage, firebaseAPI, signInWithAppleService) }
    public var timeEntriesEnvironment: TimeEntriesEnvironment { (api, dateService) }    
}
