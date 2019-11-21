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
        
    public init(api: APIProtocol, keychain: KeychainProtocol)
    {
        self.api = api
        self.keychain = keychain
    }
}

// Sub-environments
extension AppEnvironment
{
    public var loginEnvironment: LoginEnvironment { (api, keychain) }
}
