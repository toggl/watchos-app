//
//  TimeEntry.swift
//  TogglWatch WatchKit Extension
//
//  Created by Ricardo Sánchez Sotres on 15/10/2019.
//  Copyright © 2019 Toggl. All rights reserved.
//

import Foundation

public struct TimeEntry: Equatable, Identifiable
{
    public var id: Int
    public var description: String
    public var start: Date
    public var duration: Double
    public var billable: Bool

    public var workspaceId: Int
    public var projectId: Int?
    public var taskId: Int?
    public var tagIds: [Int]?

    public static func createNew(withDescription description: String, workspaceId: Int, billable: Bool = false, projectId: Int? = nil, taskId: Int? = nil, tagIds: [Int] = []) -> TimeEntry
    {
        return TimeEntry(
            id: Int.random(in: 0..<100000),
            description: description,
            start: Date(),
            duration: -1,
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

extension TimeEntry: Codable
{
    private var createdWith: String { "AppleWatchApp" }
    
    private var encodedDuration: Int64
    {
        guard duration < 0 else { return Int64(-start.timeIntervalSince1970) }
        return Int64(duration)
    }

    private enum CodingKeys: String, CodingKey
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
    
    private enum EncodeKeys: String, CodingKey
    {
        case description
        case start
        case billable
        case duration
        
        case workspaceId = "workspace_id"
        case projectId = "project_id"
        case taskId = "task_id"
        case tagIds = "tag_ids"
        case createdWith = "created_with"
    }
    
    public func encode(to encoder: Encoder) throws
    {
        var container = encoder.container(keyedBy: EncodeKeys.self)
        
        try container.encode(description, forKey: .description)
        try container.encode(start.toServerEncodedDateString(), forKey: .start)
        try container.encode(billable, forKey: .billable)
        try container.encode(encodedDuration, forKey: .duration)
        try container.encode(workspaceId, forKey: .workspaceId)
        try container.encode(projectId, forKey: .projectId)
        try container.encode(taskId, forKey: .taskId)
        try container.encode(tagIds ?? [Int](), forKey: .tagIds)
        try container.encode(createdWith, forKey: .createdWith)
    }
}

#if DEBUG
public extension TimeEntry
{
    static var dummyEntries: [TimeEntry]
    {
        return [
            TimeEntry(id: 0, description: "One time entry", start: Date(), duration: 1000, billable: false, workspaceId: 0, projectId: 0, taskId: 0, tagIds: []),
            TimeEntry(id: 1, description: "Another time entry", start: Date(), duration: 1000, billable: false, workspaceId: 0, projectId: nil, taskId: nil, tagIds: []),
            TimeEntry(id: 2, description: "", start: Date(), duration: 1000, billable: false, workspaceId: 0, projectId: nil, taskId: nil, tagIds: [])
        ]
    }
}
#endif
