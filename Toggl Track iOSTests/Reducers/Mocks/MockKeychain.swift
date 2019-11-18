//
//  MockKeychain.swift
//  Toggl Track iOSTests
//
//  Created by Ricardo Sánchez Sotres on 18/11/2019.
//  Copyright © 2019 Toggl. All rights reserved.
//

import Foundation
@testable import TogglTrack

public class MockKeychain: KeychainProtocol
{
    public var apiToken: String?
    
    public func setApiToken(token: String)
    {
        apiToken = token
    }
    
    public func getApiToken() -> String?
    {
        return apiToken
    }
    
    public func deleteApiToken()
    {
        apiToken = nil
    }
    
    
}
