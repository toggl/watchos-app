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
            if store.state.runningEntry != nil {
                NavigationLink(destination: TimeEntryDetailView(store: self.store, timeEntry: store.state.runningEntry!)) {
                    RunningTimeEntryView(store.state.runningEntry!, onStopAction: { self.store.send(.stopRunningEntry) })
                }
                .listRowPlatterColor(Color.black)
            }
            ForEach(store.state.groupedTimelineEntries, id: \.day) { group in
                Section(header: Text(group.dayString)) {
                    ForEach(group.timeEntries, id: \.id) { timeEntry in
                        NavigationLink(destination:
                        TimeEntryDetailView(store: self.store, timeEntry: timeEntry)) {
                            TimeEntryCellView(
                                timeEntry,
                                onContinueTimeEntry: { te in self.store.send(.continueEntry(te.id)) },
                                onDeleteTimeEntry: { te in self.store.send(.deleteEntry(te.id)) }
                            )
                        }
                        .listRowInsets(EdgeInsets(top: 0, leading: 4, bottom: 0, trailing: 4))
                        .listRowPlatterColor(Color.clear)
                    }
                }
            }
        }
        .animation(Animation.default)
    }
}
