//
//  ContentView.swift
//  TogglWatch WatchKit Extension
//
//  Created by Ricardo Sánchez Sotres on 15/10/2019.
//  Copyright © 2019 Toggl. All rights reserved.
//

import SwiftUI
import Combine
import Architecture
import Core

var globalReducer: Reducer<AppState, AppAction, AppEnvironment> = Reducer { state, action, environment in
    switch action {
    case .timelineEntries(_):
        return .empty
    case .projects(_):
        return .empty
    case .workspaces(_):
        return .empty
    case .loadAll:
        return .fromActions(actions: .workspaces(.loadWorkspaces), .projects(.loadProjects), .timelineEntries(.loadEntries))
    }
}

var appReducer: Reducer<AppState, AppAction, AppEnvironment> = combine(
    globalReducer,
    pullback(
        timelineReducer,
        value: \.timeline.timeEntries,
        action: \.timelineEntries,
        environment: \AppEnvironment.api
    ),
    pullback(
        projectReducer,
        value: \.timeline.projects,
        action: \.projects,
        environment: \.api
    ),
    pullback(
        workspaceReducer,
        value: \.timeline.workspaces,
        action: \.workspaces,
        environment: \.api
    )
)

struct ContentView: View
{
    @ObservedObject var store: Store<AppState, AppAction, AppEnvironment>
    
    var body: some View {
        TimelineView(
            store: store.view(
                value: { $0.timeline },
                action: { .timelineEntries($0)}
            )
        )
        .onAppear {
            self.store.send(.loadAll)
        }
    }
}

#if DEBUG
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView(store: Store(
            initialValue: AppState(),
            reducer: appReducer,
            environment: AppEnvironment())
        )
    }
}
#endif