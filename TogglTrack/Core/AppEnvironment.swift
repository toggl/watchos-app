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
    public let keychain: KeychainProtocol
    public let dateService: DateServiceProtocol
        
    public init(api: APIProtocol, keychain: KeychainProtocol, dateService: DateServiceProtocol)
    {
        self.api = api
        self.keychain = keychain
        self.dateService = dateService
    }
}

// Sub-environments
extension AppEnvironment
{
    public var loginEnvironment: LoginEnvironment { (api, keychain) }
    public var timeEntriesEnvironment: TimeEntriesEnvironment { (api, dateService) }    
}
