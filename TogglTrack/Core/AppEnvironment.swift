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
    public let api: API
    public let keychainService = KeychainService();
    
    public var userEnvironment: UserEnvironment { (api, keychainService) }
        
    public init(api: API)
    {
        self.api = api
    }
}
