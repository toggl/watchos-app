//
//  WorkspacesReducer.swift
//  TogglWatch WatchKit Extension
//
//  Created by Ricardo Sánchez Sotres on 05/11/2019.
//  Copyright © 2019 Toggl. All rights reserved.
//

import Foundation
import Architecture
import Model
import TogglAPI
import Combine

public var workspaceReducer: Reducer<[Int: Workspace], WorkspaceAction, API> = Reducer { state, action, api in
    switch action {
        case .loadWorkspaces:
            return loadWorkspacesEffect(api)
        case let .setWorkspaces(workspaces):
            state = [:]
            for workspace in workspaces
            {
                state[workspace.id] = workspace
            }
            return .empty
    }
}

private func loadWorkspacesEffect(_ api: API) -> Effect<WorkspaceAction>
{
    return Effect {
        api.loadWorkspaces()
            .map { workspaces in .setWorkspaces(workspaces) }
            .catch { _ in Just(.setWorkspaces([])) }
            .eraseToAnyPublisher()
    }
}
