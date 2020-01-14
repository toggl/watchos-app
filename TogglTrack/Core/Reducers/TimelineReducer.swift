//
//  TimelineReducer.swift
//  TogglWatch WatchKit Extension
//
//  Created by Ricardo Sánchez Sotres on 15/10/2019.
//  Copyright © 2019 Toggl. All rights reserved.
//

import Foundation
import Combine

public typealias TimeEntriesState = (timeEntries: [TimeEntry.ID: TimeEntry], runningTimeEntry: Int?)
public typealias TimeEntriesEnvironment = (api: APIProtocol, dateService: DateServiceProtocol)

public var timelineReducer: Reducer<TimeEntriesState, TimelineAction, TimeEntriesEnvironment, AppAction> = Reducer { state, action, environment in
    switch action {
        
    case .stopRunningEntry:
        guard let runningId = state.runningTimeEntry,
            let runningTimeEntry = state.timeEntries[runningId] else {
                return Just(.setError(TimelineError.NoRunningEntry))
                .eraseToEffect()
        }
        
        var copyTE = runningTimeEntry
        copyTE.duration = environment.dateService.date.timeIntervalSince(runningTimeEntry.start)
        
        return Effect.concat(
            Just(.setLoading(true)).eraseToEffect(),
            updateTimeEntryEffect(environment.api, timeEntry: copyTE),
            Just(.setLoading(false)).eraseToEffect()
        )
            
    case .deleteEntry(let id):
        guard let timeEntry = state.timeEntries[id] else {
            return Just(.setError(TimelineError.CantFindTimeEntry))
                .eraseToEffect()
        }

        return Effect.concat(
            Just(.setLoading(true)).eraseToEffect(),
            deleteEffect(environment.api, workspace: timeEntry.workspaceId, id: timeEntry.id),
            Just(.setLoading(false)).eraseToEffect()
        )
        
    case .entryDeleted(let id):
        guard let _ = state.timeEntries[id] else {
            return Just(.setError(TimelineError.CantFindTimeEntry))
                .eraseToEffect()
        }
        state.timeEntries[id] = nil
        return .empty
        
    case .continueEntry(let id):
        guard let timeEntry = state.timeEntries[id] else {
            return Just(.setError(TimelineError.CantFindTimeEntry))
                .eraseToEffect()
        }
        var copyTE = timeEntry
        copyTE.start = environment.dateService.date
        copyTE.duration = -1
                
        return Effect.concat(
            Just(.setLoading(true)).eraseToEffect(),
            startTimeEntryEffect(environment.api, timeEntry: copyTE),
            Just(.setLoading(false)).eraseToEffect()
        )
        
    case let .startTimeEntry(timeEntry):
        if let runningId = state.runningTimeEntry,
            let runningTimeEntry = state.timeEntries[runningId]
        {
            var copyTE = runningTimeEntry
            copyTE.duration = environment.dateService.date.timeIntervalSince(runningTimeEntry.start)
            state.timeEntries[copyTE.id] = copyTE
        }
        
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


private func deleteEffect(_ api: APIProtocol, workspace: Int, id: Int) -> Effect<AppAction>
{
    api.deleteTimeEntry(workspaceId: workspace, timeEntryId: id)
        .toEffect(
            map: { .timeline(.entryDeleted(id)) },
            catch: { error in .setError(error) }
        )
}

private func startTimeEntryEffect(_ api: APIProtocol, timeEntry: TimeEntry) -> Effect<AppAction>
{
    api.startTimeEntry(timeEntry: timeEntry)
        .toEffect(
            map: { .timeline(.startTimeEntry($0)) },
            catch: { error in .setError(error) }
        )
}

private func updateTimeEntryEffect(_ api: APIProtocol, timeEntry: TimeEntry) -> Effect<AppAction>
{
    api.updateTimeEntry(timeEntry: timeEntry)
        .toEffect(
            map: { .timeline(.entryUpdated($0)) },
            catch: { error in .setError(error) }
        )
}
