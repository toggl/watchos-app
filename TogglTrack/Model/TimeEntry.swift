//
//  TimeEntry.swift
//  TogglWatch WatchKit Extension
//
//  Created by Ricardo Sánchez Sotres on 15/10/2019.
//  Copyright © 2019 Toggl. All rights reserved.
//

import Foundation

public struct TimeEntry: Codable, Equatable, Identifiable
{
    public var id: Int
    public var description: String
    public var start: Date
    public var duration: Double?
    public var billable: Bool
        
    public var workspaceId: Int
    public var projectId: Int?
    public var taskId: Int?
    public var tagIds: [Int]?
    
    enum CodingKeys: String, CodingKey
    {
        case id
        case description
        case start
        case duration
        case billable
   
        case workspaceId = "workspace_id"
        case projectId = "project_id"
        case taskId = "task_id"
        case tagIds = "tag_ids"
    }
    
    public static func createNew(withDescription description: String, workspaceId: Int, billable: Bool = false, projectId: Int? = nil, taskId: Int? = nil, tagIds: [Int] = []) -> TimeEntry
    {
        return TimeEntry(
            id: Int.random(in: 0..<100000),
            description: description,
            start: Date(),
            duration: 0,
            billable: billable,
            workspaceId: workspaceId,
            projectId: projectId,
            taskId: taskId,
            tagIds: tagIds
        )
    }
    
    public func stopped() -> TimeEntry
    {
        return TimeEntry(
            id: self.id,
            description: self.description,
            start: self.start,
            duration: self.start.distance(to: Date()),
            billable: self.billable,
            workspaceId: self.workspaceId,
            projectId: self.projectId,
            taskId: self.taskId,
            tagIds: self.tagIds
        )
    }
}

#if DEBUG
public extension TimeEntry
{
    static var dummyEntries: [TimeEntry]
    {
        return [
            TimeEntry(id: 0, description: "One time entry", start: Date(), duration: 1000, billable: false, workspaceId: 0, projectId: nil, taskId: nil, tagIds: []),
            TimeEntry(id: 1, description: "Another time entry", start: Date(), duration: 1000, billable: false, workspaceId: 0, projectId: nil, taskId: nil, tagIds: [])
        ]
    }
}
#endif
