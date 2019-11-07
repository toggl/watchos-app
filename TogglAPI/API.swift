//
//  API.swift
//  TogglWatch WatchKit Extension
//
//  Created by Ricardo Sánchez Sotres on 24/10/2019.
//  Copyright © 2019 Toggl. All rights reserved.
//

import Foundation
import Combine
import Model
import Networking

public class API
{
    private let urlSession: URLSessionProtocol
    private var cancellable: Cancellable?
    
    public init(urlSession: URLSessionProtocol = MockURLSession())
    {
        self.urlSession = urlSession        
    }
    
    public func loadEntries() -> AnyPublisher<[TimeEntry], Error>
    {
        return urlSession.load(TimeEntry.allEntries)
    }
    
    public func loadWorkspaces() -> AnyPublisher<[Workspace], Error>
    {
        return urlSession.load(Workspace.allWorkspaces)
    }
    
    public func loadClients(completion: @escaping (Result<[Client], Error>) -> Void)
    {
        loadEntities(endpoint: Client.allClients, completion: completion)
    }
    
    public func loadProjects() -> AnyPublisher<[Project], Error>
    {
        return urlSession.load(Project.allProjects)
    }
    
    public func loadTags(completion: @escaping (Result<[Tag], Error>) -> Void)
    {
        loadEntities(endpoint: Tag.allTags, completion: completion)
    }
    
    private func loadEntities<A>(endpoint: Endpoint<A>, completion: @escaping (Result<A, Error>) -> Void)
    {
        cancellable = urlSession.load(endpoint)
            .sink(
                receiveCompletion: { completed in
                    if case let .failure(error) = completed {
                        completion(.failure(error))
                    }
            },
                receiveValue: { entries in completion(.success(entries))
            })
    }
}

public extension TimeEntry
{
    static var allEntries: Endpoint<[TimeEntry]> {
        
        let jsonDecoder = JSONDecoder()
        jsonDecoder.dateDecodingStrategy = .iso8601
        
        return Endpoint<[TimeEntry]>(
            json: .get,
            url: URL(string: "https://mobile.toggl.space/api/v9/me/time_entries")!,
            headers: ["Authorization": "key=ODE3MjM4YjUyNjZkYTM0NjczZjc1ODk5N2M1MTQxY2U6YXBpX3Rva2Vu"],
            query: [:],
            decoder: jsonDecoder
        )
    }
}

public extension Workspace
{
    static var allWorkspaces: Endpoint<[Workspace]> {
        
        let jsonDecoder = JSONDecoder()
        jsonDecoder.dateDecodingStrategy = .iso8601
        
        return Endpoint<[Workspace]>(
            json: .get,
            url: URL(string: "https://mobile.toggl.space/api/v9/me/workspaces")!,
            headers: ["Authorization": "key=ODE3MjM4YjUyNjZkYTM0NjczZjc1ODk5N2M1MTQxY2U6YXBpX3Rva2Vu"],
            query: [:],
            decoder: jsonDecoder
        )
    }
}

public extension Client
{
    static var allClients: Endpoint<[Client]> {
        
        let jsonDecoder = JSONDecoder()
        jsonDecoder.dateDecodingStrategy = .iso8601
        
        return Endpoint<[Client]>(
            json: .get,
            url: URL(string: "https://mobile.toggl.space/api/v9/me/clients")!,
            headers: ["Authorization": "key=ODE3MjM4YjUyNjZkYTM0NjczZjc1ODk5N2M1MTQxY2U6YXBpX3Rva2Vu"],
            query: [:],
            decoder: jsonDecoder
        )
    }
}

public extension Project
{
    static var allProjects: Endpoint<[Project]> {
        
        let jsonDecoder = JSONDecoder()
        jsonDecoder.dateDecodingStrategy = .iso8601
        
        return Endpoint<[Project]>(
            json: .get,
            url: URL(string: "https://mobile.toggl.space/api/v9/me/projects")!,
            headers: ["Authorization": "key=ODE3MjM4YjUyNjZkYTM0NjczZjc1ODk5N2M1MTQxY2U6YXBpX3Rva2Vu"],
            query: [:],
            decoder: jsonDecoder
        )
    }
}

public extension Tag
{
    static var allTags: Endpoint<[Tag]> {
        
        let jsonDecoder = JSONDecoder()
        jsonDecoder.dateDecodingStrategy = .iso8601
        
        return Endpoint<[Tag]>(
            json: .get,
            url: URL(string: "https://mobile.toggl.space/api/v9/me/tags")!,
            headers: ["Authorization": "key=ODE3MjM4YjUyNjZkYTM0NjczZjc1ODk5N2M1MTQxY2U6YXBpX3Rva2Vu"],
            query: [:],
            decoder: jsonDecoder
        )
    }
}
