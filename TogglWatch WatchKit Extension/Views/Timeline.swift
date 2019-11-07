//
//  Timeline.swift
//  TogglWatch WatchKit Extension
//
//  Created by Ricardo Sánchez Sotres on 15/10/2019.
//  Copyright © 2019 Toggl. All rights reserved.
//

import SwiftUI
import Combine
import Architecture
import Model
import Core

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
            ForEach(store.state.timeEntryModels, id: \.id) { viewModel in
                TimeEntryCellView(viewModel: viewModel)
            }
            .onDelete { indexSet in
                guard let index = indexSet.first else { return }
                let te = self.store.state.timeEntryModels[index]
                self.store.send(.deleteEntry(id: te.id))
            }
        }
    }
}

/*
struct Timeline_Previews: PreviewProvider
{
    static var previews: some View
    {
        TimelineView(
            store: Store(
                initialValue: TimeEntry.dummyEntries,
                reducer: timelineReducer,
                environment: API()
            ),
            getCell: { Text("Entry \($0.id)") }
        )
    }
}
*/
