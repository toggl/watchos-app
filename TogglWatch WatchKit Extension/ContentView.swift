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

var combinedReducer: Reducer<AppState, AppAction, AppEnvironment> = combine(
    appReducer,
    pullback(timelineReducer,
             state: \.timeline.timeEntries,
             action: \.timelineEntries,
             environment: \.api),
    pullback(createEntityReducer(),
             state: \.timeline.workspaces,
             action: \.workspaces,
             environment: \.api),
    pullback(createEntityReducer(),
             state: \.timeline.clients,
             action: \.clients,
             environment: \.api),
    pullback(createEntityReducer(),
             state: \.timeline.projects,
             action: \.projects,
             environment: \.api),
    pullback(createEntityReducer(),
             state: \.timeline.tasks,
             action: \.tasks,
             environment: \.api),
    pullback(createEntityReducer(),
             state: \.timeline.tags,
             action: \.tags,
             environment: \.api),
    pullback(userReducer,
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
                        action: { .timeEntries($0)}
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
