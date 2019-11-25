//
//  Client.swift
//  TogglWatch WatchKit Extension
//
//  Created by Ricardo Sánchez Sotres on 15/10/2019.
//  Copyright © 2019 Toggl. All rights reserved.
//

import Foundation

public struct Client: Codable, Identifiable, Equatable
{
    public var id: Int
    public var name: String
    
    public var workspaceId: Int
    
    enum CodingKeys: String, CodingKey
    {
        case id
        case name
    
        case workspaceId = "wid"
    }
}

#if DEBUG
public extension Client
{
    var dummyClients: [Client]
    {
        return [
            Client(id: 0, name: "Client 1", workspaceId: 0)
        ]
    }
}
#endif
