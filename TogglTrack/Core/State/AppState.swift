//
//  AppState.swift
//  TogglWatch WatchKit Extension
//
//  Created by Ricardo Sánchez Sotres on 30/10/2019.
//  Copyright © 2019 Toggl. All rights reserved.
//

import Foundation

public struct TimelineState: Equatable
{
    public var runningTimeEntryID: Int? = nil
    public var timeEntries = [TimeEntry.ID: TimeEntry]()
    public var workspaces = [Workspace.ID: Workspace]()
    public var clients = [Client.ID: Client]()
    public var projects = [Project.ID: Project]()
    public var tags = [Tag.ID: Tag]()
    public var tasks = [Task.ID: Task]()
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
    public var loginState: LoginState {
        get { (user, error) }
        set {
            self.user = newValue.user
            self.error = newValue.error
        }
    }

    public var timeEntriesState: TimeEntriesState {
        get { (timeline.timeEntries, timeline.runningTimeEntryID, error) }
        set {
            self.timeline.timeEntries = newValue.timeEntries
            self.timeline.runningTimeEntryID = newValue.runningTimeEntry
            self.error = newValue.error
        }
    }
}

// Selectors
public let timeEntryModelSelector = memoize{ (state: TimelineState) -> [TimeEntryModel] in
    return state.timeEntries.values
        .compactMap { timeEntry in
            guard let workspace = state.workspaces[timeEntry.workspaceId] else { return nil }
            let project: Project? = timeEntry.projectId != nil ? state.projects[timeEntry.projectId!] : nil
            let client: Client? = project?.clientId != nil ? state.clients[project!.clientId!] : nil
            let task: Task? = timeEntry.taskId != nil ? state.tasks[timeEntry.taskId!] : nil
            let tags: [Tag]? = timeEntry.tagIds != nil ? timeEntry.tagIds?.compactMap { state.tags[$0] } : nil
            
            return TimeEntryModel(
                timeEntry: timeEntry,
                workspace: workspace,
                project: project,
                client: client,
                task: task,
                tags: tags
            )
        }
        .sorted(by: { $0.start > $1.start })
}

public let runningTimeEntrySelector = memoize({ (state: TimelineState) -> TimeEntry? in
    guard let runningID = state.runningTimeEntryID,
        let runningTE = state.timeEntries[runningID] else { return nil }
    return runningTE
})

extension TimelineState
{
    public var groupedTimeEntries: [TimeEntryGroup]
    {
        return timeEntryModelSelector(self)
            .grouped(by: { $0.start.ignoreTimeComponents() })
            .map(TimeEntryGroup.init)
            .sorted(by: { $0.day > $1.day })
    }
    
    public var runningEntry: TimeEntryModel?
    {
        guard let runningTimeEntry = runningTimeEntrySelector(self),
            let workspace = workspaces[runningTimeEntry.workspaceId] else { return nil }

        return TimeEntryModel(
            timeEntry: runningTimeEntry,
            workspace: workspace
        )
    }
}
