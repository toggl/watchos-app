//
//  ProjectsReducer.swift
//  TogglWatch WatchKit Extension
//
//  Created by Ricardo Sánchez Sotres on 30/10/2019.
//  Copyright © 2019 Toggl. All rights reserved.
//

import Foundation
import Combine

public var projectReducer: Reducer<[Int: Project], ProjectAction, APIProtocol> = Reducer { state, action, api in
    switch action {
        case .loadProjects:
            return loadProjectsEffect(api)
        case let .setProjects(projects):
            state = [:]
            for project in projects
            {
                state[project.id] = project
            }
            return .empty
    }
}

private func loadProjectsEffect(_ api: APIProtocol) -> Effect<ProjectAction>
{
    return Effect {
        api.loadProjects()
            .map { projects in .setProjects(projects) }
            .catch { error in Just(.setProjects([])) }
            .eraseToAnyPublisher()
    }
}
