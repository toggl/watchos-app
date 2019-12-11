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
    case workspaces(EntityAction<Workspace>)
    case clients(EntityAction<Client>)
    case projects(EntityAction<Project>)
    case tasks(EntityAction<Task>)
    case tags(EntityAction<Tag>)

    case timeline(TimelineAction)
    case user(LoginAction)
    case loadAll
    case setError(Error?)
    
    public var workspaces: EntityAction<Workspace>? {
        get {
            guard case let .workspaces(value) = self else { return nil }
            return value
        }
        set {
            guard case .workspaces = self, let newValue = newValue else { return }
            self = .workspaces(newValue)
        }
    }
    
    public var clients: EntityAction<Client>? {
        get {
            guard case let .clients(value) = self else { return nil }
            return value
        }
        set {
            guard case .clients = self, let newValue = newValue else { return }
            self = .clients(newValue)
        }
    }
    
    public var projects: EntityAction<Project>? {
        get {
            guard case let .projects(value) = self else { return nil }
            return value
        }
        set {
            guard case .projects = self, let newValue = newValue else { return }
            self = .projects(newValue)
        }
    }
    
    public var tasks: EntityAction<Task>? {
        get {
            guard case let .tasks(value) = self else { return nil }
            return value
        }
        set {
            guard case .tasks = self, let newValue = newValue else { return }
            self = .tasks(newValue)
        }
    }
    
    public var tags: EntityAction<Tag>? {
        get {
            guard case let .tags(value) = self else { return nil }
            return value
        }
        set {
            guard case .tags = self, let newValue = newValue else { return }
            self = .tags(newValue)
        }
    }        
    
    public var timeline: TimelineAction? {
        get {
            guard case let .timeline(value) = self else { return nil }
            return value
        }
        set {
            guard case .timeline = self, let newValue = newValue else { return }
            self = .timeline(newValue)
        }
    }
    
    public var user: LoginAction? {
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
