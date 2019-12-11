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
    public var loading: Bool = false

    public init()
    {
    }
}

// Substates
extension AppState
{
    public var timeEntriesState: TimeEntriesState {
        get { (timeline.timeEntries, timeline.runningTimeEntryID) }
        set {
            self.timeline.timeEntries = newValue.timeEntries
            self.timeline.runningTimeEntryID = newValue.runningTimeEntry
        }
    }
}

// Selectors
public let timeEntryModelSelector = memoize{ (state: TimelineState) -> [TimeEntryModel] in
    return state.timeEntries.values
        .compactMap { $0.toViewModel(state) }
        .sorted(by: { $0.start > $1.start })
}

public let runningTimeEntrySelector = memoize({ (state: TimelineState) -> TimeEntry? in
    guard let runningID = state.runningTimeEntryID,
        let runningTE = state.timeEntries[runningID] else { return nil }
    return runningTE
})

extension TimelineState
{
    public var groupedTimelineEntries: [TimeEntryGroup]
    {
        return timeEntryModelSelector(self)
            .filter({ !$0.isRunning })
            .grouped(by: { $0.start.ignoreTimeComponents() })
            .map(TimeEntryGroup.init)
            .sorted(by: { $0.day > $1.day })
    }
    
    public var runningEntry: TimeEntryModel?
    {
        guard let runningTimeEntry = runningTimeEntrySelector(self) else { return nil }

        return runningTimeEntry.toViewModel(self)
    }
    
    public func timeEntryFor(id: Int) -> TimeEntryModel?
    {
        return timeEntries[id]?.toViewModel(self)
    }
}

fileprivate extension TimeEntry
{
    func toViewModel(_ state: TimelineState) -> TimeEntryModel?
    {
        guard let workspace = state.workspaces[self.workspaceId] else { return nil }
        let project: Project? = self.projectId != nil ? state.projects[self.projectId!] : nil
        let client: Client? = project?.clientId != nil ? state.clients[project!.clientId!] : nil
        let task: Task? = self.taskId != nil ? state.tasks[self.taskId!] : nil
        let tags: [Tag]? = self.tagIds != nil ? self.tagIds?.compactMap { state.tags[$0] } : nil
        
        return TimeEntryModel(
            timeEntry: self,
            workspace: workspace,
            project: project,
            client: client,
            task: task,
            tags: tags
        )
    }
}
