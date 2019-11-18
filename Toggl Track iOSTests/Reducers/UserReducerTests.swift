//
//  UserReducerTests.swift
//  Toggl Track iOSTests
//
//  Created by Ricardo Sánchez Sotres on 18/11/2019.
//  Copyright © 2019 Toggl. All rights reserved.
//

import XCTest
import Combine
@testable import TogglTrack

class UserReducerTests: XCTestCase
{
    var reducer = userReducer
    var api = MockAPI()
    var keychain = MockKeychain()
    lazy var userEnvironment = { (api: api, keychain: keychain) }()
    
    override func setUp()
    {
        reducer = userReducer
    }

    func testLoginSendsCredentialsToAPI()
    {
        let email = "test@test.com"
        let password = "password"
        
        var userState = UserState(user: nil, error: nil)
        let action = UserAction.login(email, password)
        
        let effect = reducer.run(&userState, action, userEnvironment)
        _ = effect.run()
        
        XCTAssertEqual(api.email, email, "The reducer is not sending the email to the API")
        XCTAssertEqual(api.password, password, "The reducer is not sending the password to the API")
    }

    func testLoginSendsSetUserActionWhenSucceeds()
    {
        let didSendAction = expectation(description: #function)
        
        let email = "test@test.com"
        let password = "password"
        let mockUser = User(id: 0, apiToken: "token")
        
        var userState = UserState(user: nil, error: nil)
        let action = UserAction.login(email, password)
        api.returnedUser = mockUser
        
        let effect = reducer.run(&userState, action, userEnvironment)
        _ = effect.run()
            .sink { userAction in
                guard case let UserAction.setUser(user) = userAction else { return }
                XCTAssertEqual(mockUser, user, "User should be set after login")
                didSendAction.fulfill()
            }
        
        wait(for: [didSendAction], timeout: 1)
    }
    
    func testLoginSendsSetErrorActionWhenItFails()
    {
        let didSendAction = expectation(description: #function)
        
        let email = "test@test.com"
        let password = "password"
        
        var userState = UserState(user: nil, error: nil)
        let action = UserAction.login(email, password)
        api.returnedUser = nil
        
        let effect = reducer.run(&userState, action, userEnvironment)
        _ = effect.run()
            .sink { userAction in
                guard case let UserAction.setError(error) = userAction else { return }
                XCTAssertNotNil(error, "When login fails an error should be set")
                didSendAction.fulfill()
            }
        
        wait(for: [didSendAction], timeout: 1)
    }
    
    func testSetUserSendsCredentialsToAPI()
    {
        let user = User(id: 0, apiToken: "token")
        var userState = UserState(user: nil, error: nil)
        let action = UserAction.setUser(user)
        
        let effect = reducer.run(&userState, action, userEnvironment)
        _ = effect.run()
        
        XCTAssertEqual(api.token, user.apiToken, "Token should be set in API after setUser")
    }
    
    func testSetUserSavesAPITokenInKeychain()
    {
        let user = User(id: 0, apiToken: "token")
        var userState = UserState(user: nil, error: nil)
        let action = UserAction.setUser(user)
        
        let effect = reducer.run(&userState, action, userEnvironment)
        _ = effect.run()
        
        XCTAssertEqual(keychain.apiToken, user.apiToken, "Token should be set in API after setUser")
    }
    
    
    func testLoadUserDoesNothingIfTheresNoTokenInKeychain()
    {
        var userState = UserState(user: nil, error: nil)
        let action = UserAction.loadAPITokenAndUser
        keychain.apiToken = nil
        
        let effect = reducer.run(&userState, action, userEnvironment)
        _ = effect.run()
        
        XCTAssertNil(userState.user, "Load user should do nothing if there's no stored token")
        XCTAssertNil(userState.error, "Load user should do nothing if there's no stored token")
    }
    
    func testLoadUserSetsAPIToken()
    {
        let token = "token"
        var userState = UserState(user: nil, error: nil)
        let action = UserAction.loadAPITokenAndUser
        keychain.apiToken = token
        
        let effect = reducer.run(&userState, action, userEnvironment)
        _ = effect.run()
        
        XCTAssertEqual(api.token, token, "Load user should set the API token")
    }
    
    func testLoadUserSetsTheUserWhenSucceeds()
    {
        let didSendAction = expectation(description: #function)
                
        let token = "token"
        let mockUser = User(id: 0, apiToken: token)
        
        var userState = UserState(user: nil, error: nil)
        let action = UserAction.loadAPITokenAndUser
        keychain.apiToken = token
        api.returnedUser = mockUser
        
        let effect = reducer.run(&userState, action, userEnvironment)
        _ = effect.run()
            .sink { userAction in
                guard case let UserAction.setUser(user) = userAction else { return }
                XCTAssertEqual(mockUser, user, "User should be set after load user")
                didSendAction.fulfill()
            }
        
        wait(for: [didSendAction], timeout: 1)
    }
    
    func testLoadUserSendsSetErrorActionWhenItFails()
    {
        let didSendAction = expectation(description: #function)
        
        let token = "token"
        
        var userState = UserState(user: nil, error: nil)
        let action = UserAction.loadAPITokenAndUser
        keychain.apiToken = token
        api.returnedUser = nil
        
        let effect = reducer.run(&userState, action, userEnvironment)
        _ = effect.run()
            .sink { userAction in
                guard case let UserAction.setError(error) = userAction else { return }
                XCTAssertNotNil(error, "When load user fails an error should be set")
                didSendAction.fulfill()
            }
        
        wait(for: [didSendAction], timeout: 1)
    }
    
    func testLogoutSetsTheUserToNil()
    {
        let user = User(id: 0, apiToken: "token")
        var userState = UserState(user: user, error: nil)
        
        let action = UserAction.logout
        
        _ = reducer.run(&userState, action, userEnvironment)
        
        XCTAssertNil(userState.user, "User should be nil after logout")
    }
    
    func testLogoutDeletesTheToken()
    {
        let token = "token"
        let user = User(id: 0, apiToken: token)
        var userState = UserState(user: user, error: nil)
        
        api.token = token
        keychain.apiToken = token
        
        let action = UserAction.logout
        _ = reducer.run(&userState, action, userEnvironment)
        
        XCTAssertNil(api.token, "API token should be nil after logout")
        XCTAssertNil(keychain.apiToken, "Keychain token should be nil after logout")
    }
}
