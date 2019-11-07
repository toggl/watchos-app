//
//  Extensions.swift
//  TogglWatch WatchKit Extension
//
//  Created by Ricardo Sánchez Sotres on 28/10/2019.
//  Copyright © 2019 Toggl. All rights reserved.
//

import Foundation
import Combine

public protocol URLSessionProtocol
{
    func load<A>(_ endpoint: Endpoint<A>) -> AnyPublisher<A, Error>
}

extension URLSession: URLSessionProtocol
{
    public func load<A>(_ endpoint: Endpoint<A>) -> AnyPublisher<A, Error>
    {
        return dataTaskPublisher(for: endpoint.request)
            .tryMap { data, response in
                guard let response = response as? HTTPURLResponse else {
                    throw UnknownError()
                }
                
                guard endpoint.expectedStatusCode(response.statusCode) else {
                    throw WrongStatusCodeError(statusCode: response.statusCode, response: response)
                }
                
                return try endpoint.parse(data)
            }
            .eraseToAnyPublisher()
    }
}

#if DEBUG
public class MockURLSession: URLSessionProtocol
{
    var requests : [String:String]  = [
        "time_entries" : "timeentries",
        "workspaces" : "workspaces",
        "projects" : "projects",
        "clients" : "clients",
        "tags" : "tags",
    ]
    
    public init() {}
    
    public func load<A>(_ endpoint: Endpoint<A>) -> AnyPublisher<A, Error>
    {
        let bundle = Bundle(for: type(of: self))
        guard let resource = requests[endpoint.request.url!.lastPathComponent],
            let path = bundle.path(forResource: resource, ofType: "txt") else {
                return Fail(error: UnknownError())
                    .eraseToAnyPublisher()
        }
        
        do {
            let data = try Data(contentsOf: URL(fileURLWithPath: path))
            let result = try endpoint.parse(data)
            return Just(result)
                .setFailureType(to: Error.self)
                .eraseToAnyPublisher()
        } catch {
            return Fail(error: error)
                .eraseToAnyPublisher()
        }
    }
}
#endif
