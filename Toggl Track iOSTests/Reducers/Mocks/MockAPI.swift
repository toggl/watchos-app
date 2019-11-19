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
    var returnedError: Error = MockError.unknown
    
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
        return Empty()
            .eraseToAnyPublisher()
    }
    
    func loadWorkspaces() -> AnyPublisher<[Workspace], Error>
    {
        return Empty()
            .eraseToAnyPublisher()
    }
    
    func loadClients() -> AnyPublisher<[Client], Error>
    {
        return Empty()
            .eraseToAnyPublisher()
    }
    
    func loadProjects() -> AnyPublisher<[Project], Error>
    {
        return Empty()
            .eraseToAnyPublisher()
    }
    
    func loadTags() -> AnyPublisher<[Tag], Error>
    {
        return Empty()
            .eraseToAnyPublisher()
    }
    
    func loadTasks() -> AnyPublisher<[Task], Error>
    {
        return Empty()
            .eraseToAnyPublisher()
    }
}
