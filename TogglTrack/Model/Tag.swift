//
//  Tag.swift
//  TogglWatch WatchKit Extension
//
//  Created by Ricardo Sánchez Sotres on 15/10/2019.
//  Copyright © 2019 Toggl. All rights reserved.
//

import Foundation

public struct Tag: Codable, Identifiable, Equatable
{
    public var id: Int
    public var name: String
    
    public var workspaceId: Int

    enum CodingKeys: String, CodingKey
    {
        case id
        case name
        
        case workspaceId = "workspace_id"
    }
}

#if DEBUG
public extension Tag
{
    var dummyTags: [Tag]
    {
        return [
            Tag(id: 0, name: "😉", workspaceId: 0),
            Tag(id: 1, name: "💩", workspaceId: 0),
            Tag(id: 2, name: "Word!", workspaceId: 0)
        ]
    }
}
#endif
