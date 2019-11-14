//
//  NetworkTests.swift
//  TogglWatch Tests
//
//  Created by Ricardo Sánchez Sotres on 11/11/2019.
//  Copyright © 2019 Toggl. All rights reserved.
//

import XCTest
@testable import TogglTrack

class EndpointTests: XCTestCase
{
    func testUrlWithoutParams()
    {
        let url = URL(string: "http://www.example.com/example.json")!
        let endpoint = Endpoint<[String]>(json: .get, url: url)
        XCTAssertEqual(url, endpoint.request.url)
    }

    func testUrlWithParams()
    {
        let url = URL(string: "http://www.example.com/example.json")!
        let endpoint = Endpoint<[String]>(json: .get, url: url, query: ["foo": "bar bar"])
        XCTAssertEqual(URL(string: "http://www.example.com/example.json?foo=bar%20bar")!, endpoint.request.url)
    }

    func testUrlAdditionalParams()
    {
        let url = URL(string: "http://www.example.com/example.json?abc=def")!
        let endpoint = Endpoint<[String]>(json: .get, url: url, query: ["foo": "bar bar"])
        XCTAssertEqual(URL(string: "http://www.example.com/example.json?abc=def&foo=bar%20bar")!, endpoint.request.url)
    }

}
