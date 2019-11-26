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
    static var dummyClients: [Client]
    {
        return [
            Client(id: 0, name: "Client 1", workspaceId: 0),
            Client(id: 1, name: "Client 2 dsb fjkgds fjgjhdfsb gdsfbhjg bdfsb gdfhjksg dsfhjkg bdfsgj bdfjks gjkdsfjkl gjkdfs", workspaceId: 0)
        ]
    }
}
#endif
