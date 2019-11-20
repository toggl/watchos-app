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
        
        // This ugly code will disappear in my next PR
        return Publishers
            .Sequence<[AppAction], Never>(sequence: [.workspaces(.loadWorkspaces), .projects(.loadProjects), .timelineEntries(.loadEntries)])
            .eraseToEffect()
    }
}

var appReducer: Reducer<AppState, AppAction, AppEnvironment> = combine(
    globalReducer,
    pullback(
        timelineReducer,
        state: \.timeline.timeEntries,
        action: \.timelineEntries,
        environment: \.api
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
        state: \.userState,
        action: \.user,
        environment: \.userEnvironment
    )
)

struct ContentView: View
{
    @ObservedObject var store: Store<AppState, AppAction, AppEnvironment>
    
    var body: some View {
        Group {
            if (store.state.userState.user != nil) {
                TimelineView(store:
                    store.view(
                        state: { $0.timeline },
                        action: { .timelineEntries($0)}
                    )
                )
                .onAppear {
                    self.store.send(.user(.loadAPITokenAndUser))
                    self.store.send(.loadAll)
                }
                .contextMenu(menuItems: {
                    Button(
                        action: { self.store.send(.user(.logout)) },
                        label: {
                            VStack {
                                Image(systemName: "logout")
                                Text("Log out")
                            }
                    })
                })
            } else {
                LoginView(store:
                    store.view(
                        state: { $0.userState },
                        action: { .user($0)}
                    )
                )
            }
        }
    }
}
