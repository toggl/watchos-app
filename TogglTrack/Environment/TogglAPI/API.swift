//
//  API.swift
//  TogglWatch WatchKit Extension
//
//  Created by Ricardo Sánchez Sotres on 24/10/2019.
//  Copyright © 2019 Toggl. All rights reserved.
//

import Foundation
import Combine

public protocol APIProtocol
{
    func setAuth(token: String?)
    func loginUser(email: String, password:String) -> AnyPublisher<User, Error>
    func loadUser() -> AnyPublisher<User, Error>

    func loadEntries() -> AnyPublisher<[TimeEntry], Error>
    func loadWorkspaces() -> AnyPublisher<[Workspace], Error>
    func loadClients() -> AnyPublisher<[Client], Error>
    func loadProjects() -> AnyPublisher<[Project], Error>
    func loadTags() -> AnyPublisher<[Tag], Error>
    func loadTasks() -> AnyPublisher<[Task], Error>
    
    func deleteTimeEntry(workspaceId: Int, timeEntryId: Int) -> AnyPublisher<Void, Error>
    func startTimeEntry(timeEntry: TimeEntry) -> AnyPublisher<TimeEntry, Error>
    func updateTimeEntry(timeEntry: TimeEntry) -> AnyPublisher<TimeEntry, Error>
    func subscribePushNotification(token: TogglPushToken) -> AnyPublisher<Void, Error>
    func unsubscribePushNotification(token: TogglPushToken) -> AnyPublisher<Void, Error>
}

public class API : APIProtocol
{
    #if DEBUG
    private let baseURL: String = "https://mobile.toggl.space/api/v9/"
    #else
    private let baseURL: String = "https://mobile.toggl.com/api/v9/"
    #endif
    
    private let userAgent: String = "AppleWatchApp"
    private var appVersion: String = ""
    private var headers: [String : String]
    
    private let urlSession: URLSessionProtocol
    private var cancellable: Cancellable?
    private var jsonDecoder: JSONDecoder
    
    public init(urlSession: URLSessionProtocol)
    {
        self.urlSession = urlSession
        
        jsonDecoder = JSONDecoder()
        jsonDecoder.dateDecodingStrategy = .iso8601
        
        if let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String {
            appVersion = version
        }
        
        headers = ["User-Agent": userAgent + appVersion]
    }
    
    public func setAuth(token: String?)
    {
        guard let token = token else {
            updateAuthHeaders(with: nil)
            return
        }
        let loginData = "\(token):api_token".data(using: String.Encoding.utf8)!
        updateAuthHeaders(with: loginData)
    }
    
    public func loginUser(email: String, password: String) -> AnyPublisher<User, Error>
    {
        let loginData = "\(email):\(password)".data(using: String.Encoding.utf8)!
        updateAuthHeaders(with: loginData)

        let endpoint: Endpoint<User> = createEntityEndpoint(path: "me")
        return urlSession.load(endpoint)
    }
    
    public func loadUser() -> AnyPublisher<User, Error>
    {
        let endpoint: Endpoint<User> = createEntityEndpoint(path: "me")
        return urlSession.load(endpoint)
    }
        
    public func loadEntries() -> AnyPublisher<[TimeEntry], Error>
    {
        let endpoint: Endpoint<[TimeEntry]> = createEntitiesEndpoint(path: "me/time_entries")
        return urlSession.load(endpoint)
    }
    
    public func loadWorkspaces() -> AnyPublisher<[Workspace], Error>
    {
        let endpoint: Endpoint<[Workspace]> = createEntitiesEndpoint(path: "me/workspaces")
        return urlSession.load(endpoint)
    }
    
    public func loadClients() -> AnyPublisher<[Client], Error>
    {
        let endpoint: Endpoint<[Client]> = createEntitiesEndpoint(path: "me/clients")
        return urlSession.load(endpoint)
    }
    
    public func loadProjects() -> AnyPublisher<[Project], Error>
    {
        let endpoint: Endpoint<[Project]> = createEntitiesEndpoint(path: "me/projects")
        return urlSession.load(endpoint)
    }
    
    public func loadTags() -> AnyPublisher<[Tag], Error>
    {
        let endpoint: Endpoint<[Tag]> = createEntitiesEndpoint(path: "me/tags")
        return urlSession.load(endpoint)
    }
    
    public func loadTasks() -> AnyPublisher<[Task], Error>
    {
        let endpoint: Endpoint<[Task]> = createEntitiesEndpoint(path: "me/tasks")
        return urlSession.load(endpoint)
    }
    
    public func deleteTimeEntry(workspaceId: Int, timeEntryId: Int) -> AnyPublisher<Void, Error>
    {
        let endpoint = Endpoint<Void>(
            .delete,
            url: URL(string: baseURL + "workspaces/\(workspaceId)/time_entries/\(timeEntryId)")!,
            headers: headers)
        return urlSession.load(endpoint)
    }
    
    public func startTimeEntry(timeEntry: TimeEntry) -> AnyPublisher<TimeEntry, Error>
    {
        let endpoint =  Endpoint<TimeEntry>(
            json: .post,
            url: URL(string: baseURL + "workspaces/\(timeEntry.workspaceId)/time_entries")!,
            body: timeEntry,
            headers: headers,
            decoder: jsonDecoder
        )
        return urlSession.load(endpoint)
    }
    
    public func updateTimeEntry(timeEntry: TimeEntry) -> AnyPublisher<TimeEntry, Error>
    {
        let endpoint =  Endpoint<TimeEntry>(
            json: .put,
            url: URL(string: baseURL + "workspaces/\(timeEntry.workspaceId)/time_entries/\(timeEntry.id)")!,
            body: timeEntry,
            headers: headers,
            decoder: jsonDecoder
        )
        return urlSession.load(endpoint)
    }
    
    public func subscribePushNotification(token: TogglPushToken) -> AnyPublisher<Void, Error>
    {
        let endpoint =  Endpoint<Void>(
            json: .post,
            url: URL(string: baseURL + "me/push_services")!,
            body: token,
            headers: headers
        )
        return urlSession.load(endpoint)
    }
    
    public func unsubscribePushNotification(token: TogglPushToken) -> AnyPublisher<Void, Error>
    {
        let endpoint =  Endpoint<Void>(
            json: .delete,
            url: URL(string: baseURL + "me/push_services")!,
            body: token,
            headers: headers
        )
        return urlSession.load(endpoint)
    }
    
    private func updateAuthHeaders(with loginData: Data?)
    {
        guard let loginData = loginData else {
            headers["Authorization"] = nil
            return
        }
        
        let base64LoginString = loginData.base64EncodedString()
        let authHeader = "Basic \(base64LoginString)"
        headers["Authorization"] = authHeader
    }
    
    private func createEntitiesEndpoint<T>(path: String) -> Endpoint<[T]> where T: Decodable
    {
        return Endpoint<[T]>(
            json: .get,
            url: URL(string: baseURL + path)!,
            headers: headers,
            decoder: jsonDecoder
        )
    }
    
    private func createEntityEndpoint<T>(path: String) -> Endpoint<T> where T: Decodable
    {
        return Endpoint<T>(
            json: .get,
            url: URL(string: baseURL + path)!,
            headers: headers,
            decoder: jsonDecoder
        )
    }
}
