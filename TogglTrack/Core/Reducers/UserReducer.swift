//
//  UserReducer.swift
//  TogglWatch
//
//  Created by Juxhin Bakalli on 15/11/19.
//  Copyright © 2019 Toggl. All rights reserved.
//

import Foundation
import Combine

public typealias UserEnvironment = (api: APIProtocol, keychain: KeychainProtocol)

public var userReducer: Reducer<UserState, UserAction, UserEnvironment> = Reducer { state, action, userEnv in
    
    switch action {
        
    case let .login(email, password):
        return loginEffect(userEnv.api, email, password)
        
    case let .setUser(user):
        state.user = user
        userEnv.keychain.setApiToken(token: user.apiToken)
        userEnv.api.setAuth(token: user.apiToken)
        return .empty
        
    case let .setError(error):
        state.error = error
        return .empty
        
    case .loadAPITokenAndUser:
        guard let token = userEnv.keychain.getApiToken() else { return .empty }
        userEnv.api.setAuth(token: token)
        return loadUserEffect(userEnv.api)
        
    case .logout:
        state.user = nil
        userEnv.keychain.deleteApiToken()
        userEnv.api.setAuth(token: nil)
        return .empty
    }
}

private func loginEffect(_ api: APIProtocol, _ email: String, _ password: String) -> Effect<UserAction>
{
    api.loginUser(email: email, password: password)
        .map { user in .setUser(user) }
        .catch { error in Just(.setError(error)) }
        .eraseToEffect()
}

private func loadUserEffect(_ api: APIProtocol) -> Effect<UserAction>
{
    api.loadUser()
        .map { user in .setUser(user) }
        .catch { error in Just(.setError(error)) }
        .eraseToEffect()
}
