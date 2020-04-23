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
            .retry(3)
            .tryMap { data, response in
                guard let response = response as? HTTPURLResponse else {
                    throw NetworkingError.noData
                }
                
                guard endpoint.expectedStatusCode(response.statusCode) else {
                    throw NetworkingError.wrongStatus(response.statusCode, response)
                }
                
                return try endpoint.parse(data)
            }
            .eraseToAnyPublisher()
    }
}
