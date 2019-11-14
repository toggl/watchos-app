//
//  URLSessionTests.swift
//  TogglWatch Tests
//
//  Created by Ricardo Sánchez Sotres on 11/11/2019.
//  Copyright © 2019 Toggl. All rights reserved.
//

import XCTest
import Combine
@testable import TogglTrack

struct Person: Codable, Equatable {
    var name: String
}

let exampleJSON = """
[
    {
        "name": "Alice"
    },
    {
        "popo": "Bob"
    }
]
"""

class URLSessionTests: XCTestCase
{

    override func setUp()
    {
        super.setUp()
        URLProtocol.registerClass(URLProtocolMock.self)
    }

    override func tearDown()
    {
        super.tearDown()
        URLProtocol.unregisterClass(URLProtocolMock.self)
    }

    func testDataTaskRequest() throws
    {
        let url = URL(string: "http://www.example.com/example.json")!

        URLProtocolMock.urls[url] = StubbedResponse(response: HTTPURLResponse(url: url, statusCode: 200, httpVersion: nil, headerFields: nil)!, data: exampleJSON.data(using: .utf8)!)

        let endpoint = Endpoint<[Person]>(json: .get, url: url)
        let expectation = XCTestExpectation(description: "Stubbed network call")
        
        let _ = URLSession.shared.load(endpoint)
            .sink(
                receiveCompletion: { completed in
                    if case let .failure(error) = completed {
                        XCTFail(String(describing: error))
                    }
            },
                receiveValue: { payload in
                    XCTAssertEqual([Person(name: "Alice"), Person(name: "Bob")], payload)
                    expectation.fulfill()
            })
    }
}
