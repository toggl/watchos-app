//
//  AppAction.swift
//  TogglWatch WatchKit Extension
//
//  Created by Ricardo Sánchez Sotres on 06/11/2019.
//  Copyright © 2019 Toggl. All rights reserved.
//

import Foundation

public enum AppAction
{
    case timelineEntries(TimelineAction)
    case projects(ProjectAction)
    case workspaces(WorkspaceAction)
    case user(UserAction)
    case loadAll
    
    public var timelineEntries: TimelineAction? {
        get {
            guard case let .timelineEntries(value) = self else { return nil }
            return value
        }
        set {
            guard case .timelineEntries = self, let newValue = newValue else { return }
            self = .timelineEntries(newValue)
        }
    }
    
    public var projects: ProjectAction? {
        get {
            guard case let .projects(value) = self else { return nil }
            return value
        }
        set {
            guard case .projects = self, let newValue = newValue else { return }
            self = .projects(newValue)
        }
    }
    
    public var workspaces: WorkspaceAction? {
        get {
            guard case let .workspaces(value) = self else { return nil }
            return value
        }
        set {
            guard case .workspaces = self, let newValue = newValue else { return }
            self = .workspaces(newValue)
        }
    }
    
    public var user: UserAction? {
        get {
            guard case let .user(value) = self else { return nil }
            return value
        }
        set {
            guard case .user = self, let newValue = newValue else { return }
            self = .user(newValue)
        }
    }
}
