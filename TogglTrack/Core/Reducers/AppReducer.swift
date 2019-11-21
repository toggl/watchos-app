//
//  AppReducer.swift
//  TogglWatch WatchKit Extension
//
//  Created by Ricardo Sánchez Sotres on 19/11/2019.
//  Copyright © 2019 Toggl. All rights reserved.
//

import Foundation
import Combine

public var appReducer: Reducer<AppState, AppAction, AppEnvironment> = Reducer { state, action, environment in
    switch action {
    case .timeEntries(_),
         .projects(_),
         .workspaces(_),
         .user(_),
         .clients(_),
         .tasks(_),
         .tags(_):
        return .empty
    case .loadAll:
        return loadAllEffect(environment.api)
    case .setError(_):
        return .empty
    }
}

private func loadAllEffect(_ api: APIProtocol) -> Effect<AppAction>
{
    Publishers.MergeMany(
        api.loadWorkspaces()
            .map { .workspaces(.setEntities($0)) }
            .eraseToAnyPublisher(),
        api.loadClients()
            .map { .clients(.setEntities($0)) }
            .eraseToAnyPublisher(),
        api.loadProjects()
            .map { .projects(.setEntities($0)) }
            .eraseToAnyPublisher(),
        api.loadTasks()
            .map { .tasks(.setEntities($0)) }
            .eraseToAnyPublisher(),
        api.loadTags()
            .map { .tags(.setEntities($0)) }
            .eraseToAnyPublisher(),
        api.loadEntries()
            .map { .timeEntries(.setEntries($0)) }
            .eraseToAnyPublisher()
    )
        .catch { Just(.setError($0)) }
        .eraseToEffect()
}
