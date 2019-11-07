//
//  Workspace.swift
//  TogglWatch WatchKit Extension
//
//  Created by Ricardo Sánchez Sotres on 15/10/2019.
//  Copyright © 2019 Toggl. All rights reserved.
//

import Foundation

public struct Workspace: Codable
{
    public var id: Int
    public var name: String
    public var admin: Bool
    
     enum CodingKeys: String, CodingKey
     {
         case id
         case name
         case admin
     }
}

#if DEBUG
public extension Workspace
{
    static var dummyWorkspace: Workspace
    {
        return Workspace(id: 0, name: "Workspace", admin: false)
    }
}
#endif
