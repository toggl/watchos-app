//
//  TimelineReducer.swift
//  TogglWatch WatchKit Extension
//
//  Created by Ricardo Sánchez Sotres on 15/10/2019.
//  Copyright © 2019 Toggl. All rights reserved.
//

import Foundation
import Combine

public typealias TimeEntriesState = (timeEntries: [TimeEntry.ID: TimeEntry], runningTimeEntry: Int?, error: Error?)

public var timelineReducer: Reducer<TimeEntriesState, TimelineAction, APIProtocol> = Reducer { state, action, api in
    switch action {
        
    case .startEntry(let description, let workspace):
        let te  = TimeEntry.createNew(withDescription: description, workspaceId: workspace.id)
        state.timeEntries[te.id] = te
        state.runningTimeEntry = te.id
        return .empty
        
    case .stopRunningEntry:
        guard let runningId = state.runningTimeEntry,
            let runningTimeEntry = state.timeEntries[runningId] else {
            return Just(.setError(TimelineError.CantFindRunningTimeEntryId))
                .eraseToEffect()
        }
        let stopped = state.timeEntries[runningId]?.stopped()
        state.timeEntries[runningId] = stopped
        state.runningTimeEntry = nil
        return .empty
        
    case .deleteEntry(let id):
        guard let timeEntry = state.timeEntries[id] else {
            return Just(.setError(TimelineError.CantFindIndexOfTimeEntryToDelete))
                .eraseToEffect()
        }
        return deleteEffect(api, workspace: timeEntry.workspaceId, id: timeEntry.id)
        
    case .entryDeleted(let id):
        guard let _ = state.timeEntries[id] else {
            return Just(.setError(TimelineError.CantFindIndexOfTimeEntryToDelete))
                .eraseToEffect()
        }
        
        state.timeEntries[id] = nil
        
        return .empty
        
    case let .setError(error):
        state.error = error
        return .empty
    }
}


private func deleteEffect(_ api: APIProtocol, workspace: Int, id: Int) -> Effect<TimelineAction>
{
    api.deleteTimeEntry(workspaceId: workspace, timeEntryId: id)
        .map { TimelineAction.entryDeleted(id) }
        .catch { error in Just(.setError(error)) }
        .eraseToEffect()
}
