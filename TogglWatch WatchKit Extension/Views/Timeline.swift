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
    @EnvironmentObject var store: Store<AppState, AppAction, AppEnvironment>
    @State var visibleActionId: Int = -1
    
    public var body: some View {
        Group {            
            if store.state.timeline.groupedTimelineEntries.isEmpty {
                if store.state.loading {
                    EmptyView()
                } else {
                    EmptyTimelineView {
                        self.store.send(.loadAll(force: true))
                    }
                }
            } else {
                List {
                    if store.state.timeline.runningEntry != nil {
                        NavigationLink(destination: TimeEntryDetailView(timeEntryId: store.state.timeline.runningEntry!.id).environmentObject(store)) {
                            RunningTimeEntryView(store.state.timeline.runningEntry!, onStopAction: { self.store.send(.timeline(.stopRunningEntry)) })
                        }
                        .listRowPlatterColor(Color.black)
                    }
                    ForEach(store.state.timeline.groupedTimelineEntries, id: \.day) { group in
                        Section(header: Text(group.dayString)) {
                            ForEach(group.timeEntries, id: \.id) { timeEntry in
                                NavigationLink(
                                    destination:
                                TimeEntryDetailView(timeEntryId: timeEntry.id).environmentObject(self.store),
                                    label: {
                                        TimeEntryCellView(
                                            timeEntry,
                                            onContinueTimeEntry: { te in self.store.send(.timeline(.continueEntry(te.id))) },
                                            onDeleteTimeEntry: { te in self.store.send(.timeline(.deleteEntry(te.id))) },
                                            visibleActionId: self.$visibleActionId
                                        )
                                })
                                .listRowInsets(EdgeInsets(top: 0, leading: 4, bottom: 0, trailing: 4))
                                .listRowPlatterColor(Color.clear)
                            }
                        }
                    }
                }
                .animation(Animation.default)
                .navigationBarTitle("Toggl")
            }
        }
    }
}
