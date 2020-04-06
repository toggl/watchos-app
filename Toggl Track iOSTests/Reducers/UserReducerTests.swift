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
    var firebaseAPI = MockFirebaseAPI()
    var pushStorage = MockPushTokenStorage()
    var signInWithApple = MockSignInWithAppleService()
    lazy var userEnvironment = { (api: api, keychain: keychain, pushTokenStorage: pushStorage, firebaseAPI: firebaseAPI, signInWithApple: signInWithApple) }()
    
    override func setUp()
    {
        reducer = loginReducer
    }

    func testLoginSendsCredentialsToAPI()
    {
        let email = "test@test.com"
        let password = "password"
        
        var userState: User? = nil
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
        
        var userState: User? = nil
        let action = LoginAction.login(email, password)
        api.returnedUser = mockUser
        
        let effect = reducer.run(&userState, action, userEnvironment)
        _ = effect
            .sink { userAction in
                guard case let .user(.setUser(user)) = userAction else { return }
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
        
        var userState: User? = nil
        let action = LoginAction.login(email, password)
        api.returnedUser = nil
        
        let effect = reducer.run(&userState, action, userEnvironment)
        _ = effect
            .sink { userAction in
                guard case let .setError(error) = userAction else { return }
                XCTAssertNotNil(error, "When login fails an error should be set")
                didSendAction.fulfill()
            }
        
        wait(for: [didSendAction], timeout: 1)
    }

    func testLoginWithAppleSendsCredentialsToAPI()
    {
        let token = "abcdef"

        var userState: User? = nil
        let action = LoginAction.loginWithApple(token)

        _ = reducer.run(&userState, action, userEnvironment)

        XCTAssertEqual(api.appleToken, token, "The reducer is not sending the token to the API")
    }

    func testLoginWithAppleSendsSetUserActionWhenSucceeds()
    {
        let didSendAction = expectation(description: #function)

        let token = "abcdef"
        let mockUser = User(id: 0, apiToken: "token")

        var userState: User? = nil
        let action = LoginAction.loginWithApple(token)
        api.returnedUser = mockUser

        let effect = reducer.run(&userState, action, userEnvironment)
        _ = effect
            .sink { userAction in
                guard case let .user(.setUser(user)) = userAction else { return }
                XCTAssertEqual(mockUser, user, "User should be set after login")
                didSendAction.fulfill()
            }

        wait(for: [didSendAction], timeout: 1)
    }

    func testLoginWithAppleSendsSetErrorActionWhenItFails()
    {
        let didSendAction = expectation(description: #function)

        let token = "abcdef"


        var userState: User? = nil
        let action = LoginAction.loginWithApple(token)
        api.returnedUser = nil

        let effect = reducer.run(&userState, action, userEnvironment)
        _ = effect
            .sink { userAction in
                guard case let .setError(error) = userAction else { return }
                XCTAssertNotNil(error, "When login fails an error should be set")
                didSendAction.fulfill()
            }

        wait(for: [didSendAction], timeout: 1)
    }

    func testSetUserSendsCredentialsToAPI()
    {
        let user = User(id: 0, apiToken: "token")
        var userState: User? = nil
        let action = LoginAction.setUser(user)
        
        _ = reducer.run(&userState, action, userEnvironment)
        
        XCTAssertEqual(api.token, user.apiToken, "Token should be set in API after setUser")
    }
    
    func testSetUserSavesAPITokenInKeychain()
    {
        let user = User(id: 0, apiToken: "token")
        var userState: User? = nil
        let action = LoginAction.setUser(user)
        
        _ = reducer.run(&userState, action, userEnvironment)
        
        XCTAssertEqual(keychain.apiToken, user.apiToken, "Token should be set in API after setUser")
    }
    
    
    func testLoadUserDoesNothingIfTheresNoTokenInKeychain()
    {
        var userState: User? = nil
        let action = LoginAction.loadAPITokenAndUser
        keychain.apiToken = nil
        
        _ = reducer.run(&userState, action, userEnvironment)
        
        XCTAssertNil(userState, "Load user should do nothing if there's no stored token")
    }
    
    func testLoadUserSetsAPIToken()
    {
        let token = "token"
        var userState: User? = nil
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
        
        var userState: User? = nil
        let action = LoginAction.loadAPITokenAndUser
        keychain.apiToken = token
        api.returnedUser = mockUser
        
        let effect = reducer.run(&userState, action, userEnvironment)
        _ = effect
            .sink { userAction in
                guard case let .user(.setUser(user)) = userAction else { return }
                XCTAssertEqual(mockUser, user, "User should be set after load user")
                didSendAction.fulfill()
            }
        
        wait(for: [didSendAction], timeout: 1)
    }
    
    func testLoadUserSendsSetErrorActionWhenItFails()
    {
        let didSendAction = expectation(description: #function)
        
        let token = "token"
        
        var userState: User? = nil
        let action = LoginAction.loadAPITokenAndUser
        keychain.apiToken = token
        api.returnedUser = nil
        
        let effect = reducer.run(&userState, action, userEnvironment)
        _ = effect
            .sink { userAction in
                guard case let .setError(error) = userAction else { return }
                XCTAssertNotNil(error, "When load user fails an error should be set")
                didSendAction.fulfill()
            }
        
        wait(for: [didSendAction], timeout: 1)
    }
    
    func testLogoutSetsTheUserToNil()
    {
        var userState: User? = User(id: 0, apiToken: "token")
        
        let action = LoginAction.logout
        
        _ = reducer.run(&userState, action, userEnvironment)
        
        XCTAssertNil(userState, "User should be nil after logout")
    }
    
    func testLogoutDeletesTheToken()
    {
        let didSendAction = expectation(description: #function)
        
        let token = "token"
        var userState: User? = User(id: 0, apiToken: token)
        
        api.token = token
        keychain.apiToken = token
        
        let action = LoginAction.logout
        let effect = reducer.run(&userState, action, userEnvironment)
        _ = effect.sink { userAction in
            guard case .workspaces(.clear) = userAction else { return }
            XCTAssertNil(self.api.token, "API token should be nil after logout")
            XCTAssertNil(self.keychain.apiToken, "Keychain token should be nil after logout")
            didSendAction.fulfill()
        }
        
        wait(for: [didSendAction], timeout: 1)
    }
}
