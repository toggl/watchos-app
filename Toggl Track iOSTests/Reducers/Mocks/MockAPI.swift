//
//  MockAPI.swift
//  Toggl Track iOSTests
//
//  Created by Ricardo Sánchez Sotres on 18/11/2019.
//  Copyright © 2019 Toggl. All rights reserved.
//

import Foundation
import Combine
@testable import TogglTrack

public enum MockError: Error
{
    case unknown
}

class MockAPI: APIProtocol
{
    var email: String?
    var password: String?
    var token: String?
    
    var returnedUser: User?
    var returnedTimeEntries: [TimeEntry]?
    var returnedWorkspaces: [Workspace]?
    var returnedClients: [Client]?
    var returnedProjects: [Project]?
    var returnedTasks: [Task]?
    var returnedTags: [Tag]?
    
    var returnedError: Error = MockError.unknown
    var returnStartedTimeEntry: TimeEntry?
    
    var deleteCalled = false
    
    func setAuth(token: String?)
    {
        self.token = token
    }
    
    func loginUser(email: String, password: String) -> AnyPublisher<User, Error>
    {
        self.email = email
        self.password = password
        
        guard let user = returnedUser else {
            return Fail(error: returnedError)
                .eraseToAnyPublisher()
        }
        
        return Just(user)
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()
    }
    
    func loadUser() -> AnyPublisher<User, Error>
    {
        guard let user = returnedUser else {
            return Fail(error: returnedError)
                .eraseToAnyPublisher()
        }
        
        return Just(user)
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()
    }
    
    func loadEntries() -> AnyPublisher<[TimeEntry], Error>
    {
        guard let timeEntries = returnedTimeEntries else {
            return Fail(error: returnedError)
                .eraseToAnyPublisher()
        }
        
        return Just(timeEntries)
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()
    }
    
    func loadWorkspaces() -> AnyPublisher<[Workspace], Error>
    {
        guard let workspaces = returnedWorkspaces else {
            return Fail(error: returnedError)
                .eraseToAnyPublisher()
        }
        
        return Just(workspaces)
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()
    }
    
    func loadClients() -> AnyPublisher<[Client], Error>
    {
        guard let clients = returnedClients else {
            return Fail(error: returnedError)
                .eraseToAnyPublisher()
        }
        
        return Just(clients)
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()
    }
    
    func loadProjects() -> AnyPublisher<[Project], Error>
    {
        guard let projects = returnedProjects else {
            return Fail(error: returnedError)
                .eraseToAnyPublisher()
        }
        
        return Just(projects)
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()
    }
    
    func loadTags() -> AnyPublisher<[Tag], Error>
    {
        guard let tags = returnedTags else {
            return Fail(error: returnedError)
                .eraseToAnyPublisher()
        }
        
        return Just(tags)
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()
    }
    
    func loadTasks() -> AnyPublisher<[Task], Error>
    {
        guard let tasks = returnedTasks else {
            return Fail(error: returnedError)
                .eraseToAnyPublisher()
        }
        
        return Just(tasks)
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()
    }
    
    func deleteTimeEntry(workspaceId: Int, timeEntryId: Int) -> AnyPublisher<Void, Error>
    {
        deleteCalled = true
        return Empty()
            .eraseToAnyPublisher()
    }
    
    func startTimeEntry(timeEntry: TimeEntry) -> AnyPublisher<TimeEntry, Error>
    {
        guard let returnStartedTimeEntry = returnStartedTimeEntry else {
            return Fail(error: returnedError)
                .eraseToAnyPublisher()
        }
        
        return Just(returnStartedTimeEntry)
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()
    }
}
