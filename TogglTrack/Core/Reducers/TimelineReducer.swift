//
//  TimelineReducer.swift
//  TogglWatch WatchKit Extension
//
//  Created by Ricardo Sánchez Sotres on 15/10/2019.
//  Copyright © 2019 Toggl. All rights reserved.
//

import Foundation
import Combine

public var timelineReducer: Reducer<TimeEntriesState, TimeEntryAction, APIProtocol> = Reducer { state, action, api in
    switch action {
        
    case .startEntry(let description, let workspace):
        let te  = TimeEntry.createNew(withDescription: description, workspaceId: workspace.id)
        state.byId[te.id] = te
        state.sorted.insert(te.id, at: 0)
        return .empty
        
    case .stopRunningEntry:
        guard let id = state.sorted.first else { return .empty /* TODO return error */ }
        let stopped = state.byId[id]?.stopped()
        state.byId[id] = stopped
        return .empty
        
    case .deleteEntry(let id):
        guard let index = state.sorted.firstIndex(where: { $0 == id }) else { return .empty /* TODO return error */ }
        state.byId[id] = nil
        state.sorted.remove(at: index)
        return .empty
        
    case .loadEntries:
        return loadEntriesEffect(api)
        
    case let .setEntries(entries):
        let sorted = entries.sorted(by: { $0.start > $1.start })
        state.byId = [:]
        state.sorted = []
        for te in sorted {
            state.sorted.append(te.id)
            state.byId[te.id] = te
        }
        return .empty
    }
}

private func loadEntriesEffect(_ api: APIProtocol) -> Effect<TimeEntryAction>
{
    api.loadEntries()
        .map { entries in .setEntries(entries) }
        .catch { _ in Just(.setEntries([])) }
        .eraseToEffect()
}
