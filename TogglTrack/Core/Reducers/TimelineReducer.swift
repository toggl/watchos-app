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
public typealias TimeEntriesEnvironment = (api: APIProtocol, dateService: DateServiceProtocol)

public var timelineReducer: Reducer<TimeEntriesState, TimelineAction, TimeEntriesEnvironment> = Reducer { state, action, environment in
    switch action {
        
    case .startEntry(let description, let workspace):
        var te  = TimeEntry.createNew(withDescription: description, workspaceId: workspace.id)
        te.start = Date()
        te.duration = -1
        return startTimeEntryEffect(environment.api, timeEntry: te)
        
    case .stopRunningEntry:
        guard let runningId = state.runningTimeEntry,
            let runningTimeEntry = state.timeEntries[runningId] else {
                return Just(.setError(TimelineError.NoRunningEntry))
                .eraseToEffect()
        }
        
        var copyTE = runningTimeEntry
        copyTE.duration = environment.dateService.date.timeIntervalSince(runningTimeEntry.start)
        return updateTimeEntryEffect(environment.api, timeEntry: copyTE)
            
    case .deleteEntry(let id):
        guard let timeEntry = state.timeEntries[id] else {
            return Just(.setError(TimelineError.CantFindTimeEntry))
                .eraseToEffect()
        }
        return deleteEffect(environment.api, workspace: timeEntry.workspaceId, id: timeEntry.id)
        
    case .entryDeleted(let id):
        guard let _ = state.timeEntries[id] else {
            return Just(.setError(TimelineError.CantFindTimeEntry))
                .eraseToEffect()
        }
        state.timeEntries[id] = nil
        return .empty
        
    case let .setError(error):
        state.error = error
        return .empty
        
    case .continueEntry(let id):
        guard let timeEntry = state.timeEntries[id] else {
            return Just(.setError(TimelineError.CantFindTimeEntry))
                .eraseToEffect()
        }
        var copyTE = timeEntry
        copyTE.start = environment.dateService.date
        copyTE.duration = -1
        return startTimeEntryEffect(environment.api, timeEntry: copyTE)
        
    case let .addTimeEntry(timeEntry):
        state.timeEntries[timeEntry.id] = timeEntry
        state.runningTimeEntry = timeEntry.id
        return .empty
        
    case let .setEntries(entries):
        var runningTE: TimeEntry? = nil
        state.timeEntries = entries.reduce([:], { acc, e in
            if e.duration < 0 {
                runningTE = e
            }
            var acc = acc
            acc[e.id] = e
            return acc
        })
        
        state.runningTimeEntry = runningTE?.id
        
        return .empty
    
    case let .entryUpdated(entry):
        state.timeEntries[entry.id] = entry
        if (entry.duration < 0) {
            state.runningTimeEntry = entry.id
        } else if (state.runningTimeEntry == entry.id) {
            state.runningTimeEntry = nil
        }
        return .empty
        
    case .clear:
        state.timeEntries = [:]
        state.runningTimeEntry = nil
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

private func startTimeEntryEffect(_ api: APIProtocol, timeEntry: TimeEntry) -> Effect<TimelineAction>
{
    api.startTimeEntry(timeEntry: timeEntry)
        .map { TimelineAction.addTimeEntry($0) }
        .catch { error in Just(.setError(error)) }
        .eraseToEffect()
}

private func updateTimeEntryEffect(_ api: APIProtocol, timeEntry: TimeEntry) -> Effect<TimelineAction>
{
    api.updateTimeEntry(timeEntry: timeEntry)
        .map { TimelineAction.entryUpdated($0) }
        .catch { error in Just(.setError(error)) }
        .eraseToEffect()
}
