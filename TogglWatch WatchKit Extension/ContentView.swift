//
//  ContentView.swift
//  TogglWatch WatchKit Extension
//
//  Created by Ricardo Sánchez Sotres on 15/10/2019.
//  Copyright © 2019 Toggl. All rights reserved.
//

import SwiftUI
import Combine
import TogglTrack

var globalReducer: Reducer<AppState, AppAction, AppEnvironment> = Reducer { state, action, environment in
    switch action {
    case .timelineEntries(_):
        return .empty
    case .projects(_):
        return .empty
    case .workspaces(_):
        return .empty
    case .user(_):
        return .empty
    case .loadAll:
        return .fromActions(actions: .workspaces(.loadWorkspaces), .projects(.loadProjects), .timelineEntries(.loadEntries))
    }
}

var appReducer: Reducer<AppState, AppAction, AppEnvironment> = combine(
    globalReducer,
    pullback(
        timelineReducer,
        state: \.timeline.timeEntries,
        action: \.timelineEntries,
        environment: \AppEnvironment.api
    ),
    pullback(
        projectReducer,
        state: \.timeline.projects,
        action: \.projects,
        environment: \.api
    ),
    pullback(
        workspaceReducer,
        state: \.timeline.workspaces,
        action: \.workspaces,
        environment: \.api
    ),
    pullback(
        userReducer,
        state: \.user,
        action: \.user,
        environment: \.api
    )
)

struct ContentView: View
{
    @ObservedObject var store: Store<AppState, AppAction, AppEnvironment>
    
    var body: some View {
        TimelineView(
            store: store.view(
                state: { $0.timeline },
                action: { .timelineEntries($0)}
            )
        )
        .onAppear {
            self.store.send(.loadAll)
        }
    }
}
