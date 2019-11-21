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
             state: \.timeEntriesState,
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
    pullback(loginReducer,
             state: \.loginState,
             action: \.user,
             environment: \.loginEnvironment
    )
)

struct ContentView: View
{
    @ObservedObject var store: Store<AppState, AppAction, AppEnvironment>
        
    init(store: Store<AppState, AppAction, AppEnvironment>)
    {
        self.store = store
        self.store.send(.user(.loadAPITokenAndUser))
    }
    
    var body: some View {
        Group {
            if(self.store.state.user == nil) {
                LoginView(store:
                    self.store.view(
                        state: { $0.loginState },
                        action: { .user($0) }
                ))
            } else {
                TimelineView(store:
                    store.view(
                        state: { $0.timeline },
                        action: { .timeEntries($0)}
                    )
                )
                .contextMenu(menuItems: {
                    Button(
                        action: { self.store.send(.user(.logout)) },
                        label: {
                            VStack {
                                //Image(systemName: "logout")
                                Text("Log out")
                            }
                    })
                })
            }
        }
    }
}
