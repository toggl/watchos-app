//
//  Project.swift
//  TogglWatch WatchKit Extension
//
//  Created by Ricardo Sánchez Sotres on 15/10/2019.
//  Copyright © 2019 Toggl. All rights reserved.
//

import Foundation

public struct Project: Codable, Identifiable, Equatable
{
    public var id: Int
    public var name: String
    public var isPrivate: Bool
    public var isActive: Bool
    public var color: String
    public var billable: Bool?
    
    public var workspaceId: Int
    public var clientId: Int?
    
    enum CodingKeys: String, CodingKey {
        
        case id
        case name
        case isPrivate = "is_private"
        case isActive = "active"
        case color
        case billable
        
        case workspaceId = "workspace_id"
        case clientId = "client_id"
    }
}

#if DEBUG
public extension Project
{
    static var dummyProjects: [Project]
    {
        return [
            Project(id: 0, name: "Project 1", isPrivate: false, isActive: true, color: "FABADA", billable: false, workspaceId: 0, clientId: 0),
            Project(id: 1, name: "Project 2 askjdb fdsfjhkg dshjfbg sdfjh bgdfs g bjksdf bjkgdsfb kj gkdfls glkudsfl kcklsd fkjbsdfkj", isPrivate: false, isActive: true, color: "FFFF00", billable: true, workspaceId: 0, clientId: 0)
        ]
    }
}
#endif
