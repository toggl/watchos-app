//
//  UserReducer.swift
//  TogglWatch
//
//  Created by Juxhin Bakalli on 15/11/19.
//  Copyright © 2019 Toggl. All rights reserved.
//

import Foundation
import Combine

public typealias UserEnvironment = (api: API, keychainService: KeychainService)

public var userReducer: Reducer<UserState, UserAction, UserEnvironment> = Reducer { state, action, userEnv in
    switch action {
    case let .login(email, password):
        return loginEffect(userEnv.api, email, password)
    case let .setUser(user):
        guard let token = user?.apiToken else {
            state.error = NoTokenError()
            return .empty
        }
        state.user = user
        userEnv.keychainService.setApiToken(token: token)
        userEnv.api.setAuth(token: token)
        return .empty
    case let .setError(error):
        state.error = error
        return .empty
    case .loadAPITokenAndUser:
        guard let token = userEnv.keychainService.getApiToken() else { return .empty }
        userEnv.api.setAuth(token: token)
        return loadUserEffect(userEnv.api)
    case .logout:
        state.user = nil
        userEnv.keychainService.deleteApiToken()
        userEnv.api.setAuth(token: "")
        return .empty
    }
}

private func loginEffect(_ api: API, _ email: String, _ password: String) -> Effect<UserAction>
{
    return Effect {
        api.loginUser(email: email, password: password)
            .map { user in .setUser(user) }
            .catch { error in Just(.setError(error)) }
            .eraseToAnyPublisher()
    }
}

private func loadUserEffect(_ api: API) -> Effect<UserAction>
{
    return Effect {
        api.loadUser()
            .map { user in .setUser(user) }
            .catch { error in Just(.setError(error)) }
            .eraseToAnyPublisher()
    }
}
