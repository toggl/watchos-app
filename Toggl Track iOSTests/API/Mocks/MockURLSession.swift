//
//  MockURLSession.swift
//  Toggl Track iOSTests
//
//  Created by Ricardo Sánchez Sotres on 14/11/2019.
//  Copyright © 2019 Toggl. All rights reserved.
//

import Foundation
import Combine
@testable import TogglTrack

struct NoValueError: Error {}

class MockURLSession: URLSessionProtocol
{
    var authHeader: String? = nil
    var userAgent: String? = nil
    var url: URL? = nil
    
    var returningValue: Any?
    
    func load<A>(_ endpoint: Endpoint<A>) -> AnyPublisher<A, Error>
    {
        authHeader = endpoint.request.value(forHTTPHeaderField: "Authorization")
        userAgent = endpoint.request.value(forHTTPHeaderField: "User-Agent")
        
        url = endpoint.request.url
        
        guard let result = returningValue as? A else {
            return Fail(error: NoValueError())
                .eraseToAnyPublisher()
        }
        return Just(result)
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()
    }
}
