//
//  Timeline.swift
//  TogglWatch WatchKit Extension
//
//  Created by Ricardo Sánchez Sotres on 15/10/2019.
//  Copyright © 2019 Toggl. All rights reserved.
//

import SwiftUI
import Combine
import TogglTrack

public struct RunningButton: View
{
    let runningTimeEntry: TimeEntryModel?
    let start: () -> ()
    let stop: () -> ()
    public var body: some View
    {
        if runningTimeEntry == nil {
            return Button("Start timer") {
                self.start()
            }
            .listRowPlatterColor(.green)
        } else {
            return Button("Stop timer") {
                self.stop()
            }
            .listRowPlatterColor(.red)
        }
    }
}

public struct TimelineView: View
{
    @ObservedObject var store: Store<TimelineState, TimelineAction, AppEnvironment>
    
    public init(store: Store<TimelineState, TimelineAction, AppEnvironment>)
    {
        self.store = store
    }
    
    public var body: some View {
        List {
            RunningButton(
                runningTimeEntry: store .state.runningEntry,
                start: { self.store.send(.startEntry("My time entry", self.store.state.workspaces.values.first!)) },
                stop: { self.store.send(.stopRunningEntry) }
            )
            ForEach(store.state.groupedTimeEntries, id: \.day) { group in
                Section(header: Text(group.dayString)) {
                    ForEach(group.timeEntries, id: \.id) { timeEntry in
                        NavigationLink(destination: TimeEntryDetailView(timeEntry: timeEntry)) {
                            TimeEntryCellView(timeEntry)
                        }
                    }
                    .onDelete { indexSet in
                        guard let index = indexSet.first else { return }
                        let te = group.timeEntries[index]
                        self.store.send(.deleteEntry(te.id))
                    }
                }
            }
        }
    }
}
