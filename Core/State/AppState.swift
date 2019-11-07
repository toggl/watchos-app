//
//  AppState.swift
//  TogglWatch WatchKit Extension
//
//  Created by Ricardo Sánchez Sotres on 30/10/2019.
//  Copyright © 2019 Toggl. All rights reserved.
//

import Foundation
import Model

public struct TimeEntriesState
{
    public var byId: [Int: TimeEntry] = [:]
    public var sorted: [Int] = []
}

public struct TimelineState
{
    public var timeEntries: TimeEntriesState = TimeEntriesState()
    public var workspaces: [Int: Workspace] = [:]
    public var clients: [Int: Client] = [:]
    public var projects: [Int: Project] = [:]
    public var tags: [Int: Tag] = [:]

}

public struct AppState
{
    public var timeline: TimelineState = TimelineState()
    public var somethingElse: Int = 0
    
    public init()
    {
    }
}

extension TimelineState
{
    public var timeEntryModels: [TimeEntryModel] {
        return timeEntries.sorted.compactMap { index in
            guard let timeEntry = timeEntries.byId[index], let workspace = workspaces[timeEntry.workspaceId] else { return nil }
            return TimeEntryModel(
                timeEntry: timeEntry,
                workspace: workspace
            )
        }
    }
    
    public var runningEntry: TimeEntryModel? {
        guard let index = timeEntries.sorted.first else { return nil }
        guard let timeEntry = timeEntries.byId[index], let workspace = workspaces[timeEntry.workspaceId] else { return nil }
        
        if timeEntry.duration != 0 {
            return nil
        }
        
        return TimeEntryModel(
            timeEntry: timeEntry,
            workspace: workspace
        )
    }
}
