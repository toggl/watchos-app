//
//  Task.swift
//  TogglWatch WatchKit Extension
//
//  Created by Ricardo Sánchez Sotres on 19/11/2019.
//  Copyright © 2019 Toggl. All rights reserved.
//

import Foundation

public struct Task: Codable, Identifiable, Equatable
{
    public var id: Int
    public var name: String
    public var active: Bool
    public var estimatedSeconds: Int
    public var trackedSeconds: Int
    
    public var projectId: Int
    public var workspaceId: Int
    public var userId: Int?

    enum CodingKeys: String, CodingKey
    {
        case id
        case name
        case active
        
        case estimatedSeconds = "estimated_seconds"
        case trackedSeconds = "tracked_seconds"
        case projectId = "project_id"
        case workspaceId = "workspace_id"
        case userId = "user_id"
    }
}
