//
//  APITests.swift
//  Toggl Track iOSTests
//
//  Created by Ricardo Sánchez Sotres on 14/11/2019.
//  Copyright © 2019 Toggl. All rights reserved.
//

import XCTest
@testable import TogglTrack

class APITests: XCTestCase
{
    func testSetsCorrectAuthWithEmailAndPassword()
    {
        let email = "email@dummy.com"
        let password = "dummyPassword"
        
        let urlSession = MockURLSession()
        urlSession.returningValue = [Tag(id: 0, name: "myTag", workspaceId: 0)]
        
        let api = API(urlSession: urlSession)
        
        api.setAuth(email: email, password: password)
        _ = api.loadTags().last()
                        
        let encoded = String(urlSession.authHeader!.dropFirst(6))
        let data = Data(base64Encoded: encoded)
        let string = String(data: data!, encoding: .utf8)!
        
        XCTAssertEqual(string, "\(email):\(password)")
    }
    
    func testSetsCorrectAuthWithToken()
    {
        let token = "abcd"
        
        let urlSession = MockURLSession()
        urlSession.returningValue = [Tag(id: 0, name: "myTag", workspaceId: 0)]
        
        let api = API(urlSession: urlSession)
        
        api.setAuth(token: token)
        _ = api.loadTags().last()
                        
        let encoded = String(urlSession.authHeader!.dropFirst(6))
        let data = Data(base64Encoded: encoded)
        let string = String(data: data!, encoding: .utf8)!
        
        XCTAssertEqual(string, "\(token):api_token")
    }
    
    func testSetsCorrectUserAgent()
    {        
        let urlSession = MockURLSession()
        urlSession.returningValue = [Tag(id: 0, name: "myTag", workspaceId: 0)]
        
        let api = API(urlSession: urlSession)
        
        _ = api.loadTags().last()
                        
        XCTAssertEqual(urlSession.userAgent!, "AppleWatchApp")
    }
    
    func testSetsTheCorrectURL()
    {
        let urlSession = MockURLSession()
        
        let api = API(urlSession: urlSession)
        
        _ = api.loadTags().last()
                        
        XCTAssertEqual(urlSession.url!, URL(string: "https://mobile.toggl.space/api/v9/me/tags"))
    }
}
