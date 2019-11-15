//
//  API.swift
//  TogglWatch WatchKit Extension
//
//  Created by Ricardo Sánchez Sotres on 24/10/2019.
//  Copyright © 2019 Toggl. All rights reserved.
//

import Foundation
import Combine

public class API
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
    
    public func setAuth(token: String)
    {
        let loginData = "\(token):api_token".data(using: String.Encoding.utf8)!
        updateAuthHeaders(with: loginData)
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
    
    public func loginUser(email: String, password: String) -> AnyPublisher<User, Error>
    {
        let loginData = "\(email):\(password)".data(using: String.Encoding.utf8)!
        updateAuthHeaders(with: loginData)

        let endpoint: Endpoint<User> = createEntityEndpoint(path: "me")
        return urlSession.load(endpoint)
            .handleEvents(
                receiveOutput: { user in
                    self.setAuth(token: user.apiToken)
                }
            )
            .eraseToAnyPublisher()
    }
    
    private func updateAuthHeaders(with loginData: Data)
    {
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
