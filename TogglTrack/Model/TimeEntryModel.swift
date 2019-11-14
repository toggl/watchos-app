//
//  TimeEntryViewModel.swift
//  TogglWatch WatchKit Extension
//
//  Created by Ricardo Sánchez Sotres on 25/10/2019.
//  Copyright © 2019 Toggl. All rights reserved.
//

import Foundation

public struct TimeEntryModel
{
    public var id: Int
    public var description: String
    public var start: Date
    public var duration: Double?
    public var billable: Bool

    public let workspace: Workspace
    public let project: Project?
    public let tags: [Tag]?
    
    public var durationString: String
    {
        guard let duration = duration else { return "" }
        return duration.toIntervalString()
    }
    
    public init(timeEntry: TimeEntry, workspace: Workspace, project: Project? = nil, tags: [Tag]? = nil)
    {
        self.id = timeEntry.id
        self.description = timeEntry.description
        self.start = timeEntry.start
        self.duration = timeEntry.duration
        self.billable = timeEntry.billable
        
        self.workspace = workspace
        self.project = project
        self.tags = tags
    }
}
