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
    var reducer = loginReducer
    var api = MockAPI()
    var keychain = MockKeychain()
    lazy var userEnvironment = { (api: api, keychain: keychain) }()
    
    override func setUp()
    {
        reducer = loginReducer
    }

    func testLoginSendsCredentialsToAPI()
    {
        let email = "test@test.com"
        let password = "password"
        
        var userState = LoginState(user: nil, error: nil)
        let action = LoginAction.login(email, password)
        
        _ = reducer.run(&userState, action, userEnvironment)
        
        XCTAssertEqual(api.email, email, "The reducer is not sending the email to the API")
        XCTAssertEqual(api.password, password, "The reducer is not sending the password to the API")
    }

    func testLoginSendsSetUserActionWhenSucceeds()
    {
        let didSendAction = expectation(description: #function)
        
        let email = "test@test.com"
        let password = "password"
        let mockUser = User(id: 0, apiToken: "token")
        
        var userState = LoginState(user: nil, error: nil)
        let action = LoginAction.login(email, password)
        api.returnedUser = mockUser
        
        let effect = reducer.run(&userState, action, userEnvironment)
        _ = effect
            .sink { userAction in
                guard case let LoginAction.setUser(user) = userAction else { return }
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
        
        var userState = LoginState(user: nil, error: nil)
        let action = LoginAction.login(email, password)
        api.returnedUser = nil
        
        let effect = reducer.run(&userState, action, userEnvironment)
        _ = effect
            .sink { userAction in
                guard case let LoginAction.setError(error) = userAction else { return }
                XCTAssertNotNil(error, "When login fails an error should be set")
                didSendAction.fulfill()
            }
        
        wait(for: [didSendAction], timeout: 1)
    }
    
    func testSetUserSendsCredentialsToAPI()
    {
        let user = User(id: 0, apiToken: "token")
        var userState = LoginState(user: nil, error: nil)
        let action = LoginAction.setUser(user)
        
        _ = reducer.run(&userState, action, userEnvironment)
        
        XCTAssertEqual(api.token, user.apiToken, "Token should be set in API after setUser")
    }
    
    func testSetUserSavesAPITokenInKeychain()
    {
        let user = User(id: 0, apiToken: "token")
        var userState = LoginState(user: nil, error: nil)
        let action = LoginAction.setUser(user)
        
        _ = reducer.run(&userState, action, userEnvironment)
        
        XCTAssertEqual(keychain.apiToken, user.apiToken, "Token should be set in API after setUser")
    }
    
    
    func testLoadUserDoesNothingIfTheresNoTokenInKeychain()
    {
        var userState = LoginState(user: nil, error: nil)
        let action = LoginAction.loadAPITokenAndUser
        keychain.apiToken = nil
        
        _ = reducer.run(&userState, action, userEnvironment)
        
        XCTAssertNil(userState.user, "Load user should do nothing if there's no stored token")
        XCTAssertNil(userState.error, "Load user should do nothing if there's no stored token")
    }
    
    func testLoadUserSetsAPIToken()
    {
        let token = "token"
        var userState = LoginState(user: nil, error: nil)
        let action = LoginAction.loadAPITokenAndUser
        keychain.apiToken = token
        
        _ = reducer.run(&userState, action, userEnvironment)
        
        XCTAssertEqual(api.token, token, "Load user should set the API token")
    }
    
    func testLoadUserSetsTheUserWhenSucceeds()
    {
        let didSendAction = expectation(description: #function)
                
        let token = "token"
        let mockUser = User(id: 0, apiToken: token)
        
        var userState = LoginState(user: nil, error: nil)
        let action = LoginAction.loadAPITokenAndUser
        keychain.apiToken = token
        api.returnedUser = mockUser
        
        let effect = reducer.run(&userState, action, userEnvironment)
        _ = effect
            .sink { userAction in
                guard case let LoginAction.setUser(user) = userAction else { return }
                XCTAssertEqual(mockUser, user, "User should be set after load user")
                didSendAction.fulfill()
            }
        
        wait(for: [didSendAction], timeout: 1)
    }
    
    func testLoadUserSendsSetErrorActionWhenItFails()
    {
        let didSendAction = expectation(description: #function)
        
        let token = "token"
        
        var userState = LoginState(user: nil, error: nil)
        let action = LoginAction.loadAPITokenAndUser
        keychain.apiToken = token
        api.returnedUser = nil
        
        let effect = reducer.run(&userState, action, userEnvironment)
        _ = effect
            .sink { userAction in
                guard case let LoginAction.setError(error) = userAction else { return }
                XCTAssertNotNil(error, "When load user fails an error should be set")
                didSendAction.fulfill()
            }
        
        wait(for: [didSendAction], timeout: 1)
    }
    
    func testLogoutSetsTheUserToNil()
    {
        let user = User(id: 0, apiToken: "token")
        var userState = LoginState(user: user, error: nil)
        
        let action = LoginAction.logout
        
        _ = reducer.run(&userState, action, userEnvironment)
        
        XCTAssertNil(userState.user, "User should be nil after logout")
    }
    
    func testLogoutDeletesTheToken()
    {
        let token = "token"
        let user = User(id: 0, apiToken: token)
        var userState = LoginState(user: user, error: nil)
        
        api.token = token
        keychain.apiToken = token
        
        let action = LoginAction.logout
        _ = reducer.run(&userState, action, userEnvironment)
        
        XCTAssertNil(api.token, "API token should be nil after logout")
        XCTAssertNil(keychain.apiToken, "Keychain token should be nil after logout")
    }
}
