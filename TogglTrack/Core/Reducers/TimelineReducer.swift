//
//  TimelineReducer.swift
//  TogglWatch WatchKit Extension
//
//  Created by Ricardo Sánchez Sotres on 15/10/2019.
//  Copyright © 2019 Toggl. All rights reserved.
//

import Foundation
import Combine

public typealias TimeEntriesState = (timeEntries: TimeEntries, error: Error?)

public var timelineReducer: Reducer<TimeEntriesState, TimeEntryAction, APIProtocol> = Reducer { state, action, api in
    switch action {
        
    case .startEntry(let description, let workspace):
        let te  = TimeEntry.createNew(withDescription: description, workspaceId: workspace.id)
        state.timeEntries.byId[te.id] = te
        state.timeEntries.sorted.insert(te.id, at: 0)
        return .empty
        
    case .stopRunningEntry:
        guard let id = state.timeEntries.sorted.first else {
            return Just(.setError(TimelineError.CantFindRunningTimeEntryId))
                .eraseToEffect()
        }
        let stopped = state.timeEntries.byId[id]?.stopped()
        state.timeEntries.byId[id] = stopped
        return .empty
        
    case .deleteEntry(let id):
        guard let index = state.timeEntries.sorted.firstIndex(where: { $0 == id }) else {
            return Just(.setError(TimelineError.CantFindIndexOfTimeentryToDelete))
            .eraseToEffect()
        }
        state.timeEntries.byId[id] = nil
        state.timeEntries.sorted.remove(at: index)
        return .empty
        
    case .loadEntries:
        return loadEntriesEffect(api)
        
    case let .setEntries(entries):
        let sorted = entries.sorted(by: { $0.start > $1.start })
        state.timeEntries.byId = [:]
        state.timeEntries.sorted = []
        for te in sorted {
            state.timeEntries.sorted.append(te.id)
            state.timeEntries.byId[te.id] = te
        }
        return .empty
        
    case .clear:
        state.timeEntries.byId = [:]
        state.timeEntries.sorted = []
        return .empty
        
    case let .setError(error):
        state.error = error
        return .empty
    }
}

private func loadEntriesEffect(_ api: APIProtocol) -> Effect<TimeEntryAction>
{
    api.loadEntries()
        .map { entries in .setEntries(entries) }
        .catch { error in Just(.setError(error)) }
        .eraseToEffect()
}
