//
//  AppState.swift
//  TogglWatch WatchKit Extension
//
//  Created by Ricardo Sánchez Sotres on 30/10/2019.
//  Copyright © 2019 Toggl. All rights reserved.
//

import Foundation

public struct TimeEntriesState
{
    public var byId: [Int: TimeEntry] = [:]
    public var sorted: [Int] = []
    public var error: Error?
}

public struct TimelineState
{
    public var timeEntries: TimeEntriesState = TimeEntriesState()
    public var workspaces: [Int: Workspace] = [:]
    public var clients: [Int: Client] = [:]
    public var projects: [Int: Project] = [:]
    public var tags: [Int: Tag] = [:]
    public var tasks: [Int: Task] = [:]
}

public struct AppState
{
    public var timeline: TimelineState = TimelineState()
    public var user: User?
    public var error: Error?

    public init()
    {
    }
}

// Substates
extension AppState
{
    public var loginState: (user: User?, error: Error?) {
        get { (user, error) }
        set {
            self.user = newValue.user
            self.error = newValue.error
        }
    }
}

// Selectors
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
