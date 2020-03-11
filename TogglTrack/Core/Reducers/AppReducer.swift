//
//  AppReducer.swift
//  TogglWatch WatchKit Extension
//
//  Created by Ricardo Sánchez Sotres on 19/11/2019.
//  Copyright © 2019 Toggl. All rights reserved.
//

import Foundation
import Combine

let refreshWhenActivatingThreshold: TimeInterval = 60 * 60

public var appReducer: Reducer<AppState, AppAction, AppEnvironment, AppAction> = Reducer { state, action, environment in
    switch action {

    case let .loadAll(force):
        let now = environment.dateService.date
        
        if force || (state.lastSync != nil && now.timeIntervalSince(state.lastSync!) > refreshWhenActivatingThreshold) {
            state.lastSync = now
            return Effect.concat(
                Just(.setLoading(true)).eraseToEffect(),
                loadAllEffect(environment.api),
                Just(.setLoading(false)).eraseToEffect()
            )
        }
        return .empty
        
    case let .loadAllForBackgroundUpdate(completion):
        let now = environment.dateService.date
        state.lastSync = now
        return Effect.concat(
            Just(.setLoading(true)).eraseToEffect(),
            loadTimeEntriesEffect(environment.api, backgroundUpdateCompletion: completion),
            Just(.setLoading(false)).eraseToEffect()
        )

    case let .setError(error):
        state.error = error
        return Just(.setLoading(false)).eraseToEffect()
    
    case let .setLoading(loading):
        state.loading = loading
        return .empty
        
    case .clients(_), .workspaces(_), .projects(_), .tags(_), .tasks(_), .timeline(_), .user(_):
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
            .map { .timeline(.setEntries($0)) }
            .eraseToAnyPublisher()
        )
        .catch { Just(.setError($0)) }
        .eraseToEffect()
}

private func loadTimeEntriesEffect(_ api: APIProtocol, backgroundUpdateCompletion: (()->())? = nil) -> Effect<AppAction>
{
    api.loadEntries()
    .map { .timeline(.setEntries($0)) }
    .handleEvents(receiveCompletion: { _ in
        backgroundUpdateCompletion?()
    })
    .catch { Just(.setError($0)) }
    .eraseToEffect()
}
