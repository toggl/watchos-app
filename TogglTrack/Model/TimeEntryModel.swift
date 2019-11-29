//
//  TimeEntryViewModel.swift
//  TogglWatch WatchKit Extension
//
//  Created by Ricardo Sánchez Sotres on 25/10/2019.
//  Copyright © 2019 Toggl. All rights reserved.
//

import Foundation
import SwiftUI

public struct TimeEntryModel
{
    public var id: Int
    public var description: String
    public var start: Date
    public var duration: Double?
    public var billable: Bool

    public let workspace: Workspace
    public let project: Project?
    public let client: Client?
    public let task: Task?
    public let tags: [Tag]?
    
    public var durationString: String?
    {
        guard let duration = duration else { return nil }
        return duration.toIntervalString()
    }
    
    public var descriptionString: String
    {
        if description != "" { return description }
        return "No description"
    }
    
    public var projectTaskClientString: String
    {
        var value = ""
        if let project = project { value.append(project.name) }
        if let task = task { value.append(": " + task.name) }
        if let client = client { value.append(" · " + client.name) }
        return value
    }
    
    public var descriptionColor: Color
    {
        if description != "" { return .white }
        return Color.togglGray
    }
    
    public var projectColor: Color
    {
        guard let project = project else { return .white }
        return Color(hex: project.color)
    }
    
    public var end: Date?
    {
        guard let duration = duration else  { return nil }
        return start.addingTimeInterval(duration)
    }
    
    public var isRunning: Bool
    {
        return duration == nil
    }
    
    public init(
        timeEntry: TimeEntry,
        workspace: Workspace,
        project: Project? = nil,
        client: Client? = nil,
        task: Task? = nil,
        tags: [Tag]? = nil)
    {
        self.id = timeEntry.id
        self.description = timeEntry.description
        self.start = timeEntry.start
        self.duration = timeEntry.duration >= 0 ? timeEntry.duration : nil
        self.billable = timeEntry.billable
        
        self.workspace = workspace
        self.project = project
        self.client = client
        self.task = task
        self.tags = tags
    }
}

public struct TimeEntryGroup
{
    public var day: Date
    public var dayString: String
    public var timeEntries: [TimeEntryModel]
    
    public init(timeEntries: [TimeEntryModel])
    {
        day = timeEntries.first!.start.ignoreTimeComponents()
        dayString = day.toDayString()
        self.timeEntries = timeEntries
    }
}
