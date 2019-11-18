//
//  FakeURLSession.swift
//  TogglWatch Tests
//
//  Created by Ricardo Sánchez Sotres on 11/11/2019.
//  Copyright © 2019 Toggl. All rights reserved.
//

import Foundation
import Combine

public class FakeURLSession: URLSessionProtocol
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
                return Fail(error: NetworkingError.unknown)
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
