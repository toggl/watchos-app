//
//  LoginReducer.swift
//  TogglWatch
//
//  Created by Juxhin Bakalli on 15/11/19.
//  Copyright © 2019 Toggl. All rights reserved.
//

import Foundation
import Combine

public typealias LoginEnvironment = (api: APIProtocol, keychain: KeychainProtocol)

public var loginReducer: Reducer<User?, LoginAction, LoginEnvironment, AppAction> = Reducer { state, action, userEnv in
    
    switch action {
        
    case let .login(email, password):
        return Effect.concat(
            Just(.setLoading(true)).eraseToEffect(),
            loginEffect(userEnv.api, email, password),
            Just(.setLoading(false)).eraseToEffect()
        )
        
    case let .setUser(user):
        state = user
        userEnv.keychain.setApiToken(token: user.apiToken)
        userEnv.api.setAuth(token: user.apiToken)
        return Just(.loadAll).eraseToEffect()
        
    case .loadAPITokenAndUser:
        guard let token = userEnv.keychain.getApiToken() else { return .empty }
        userEnv.api.setAuth(token: token)
        return Effect.concat(
            Just(.setLoading(true)).eraseToEffect(),
            loadUserEffect(userEnv.api),
            Just(.setLoading(false)).eraseToEffect()
        )
        
    case .logout:
        state = nil
        userEnv.keychain.deleteApiToken()
        userEnv.api.setAuth(token: nil)
        return Effect.fromActions(
            .workspaces(.clear),
            .clients(.clear),
            .projects(.clear),
            .tasks(.clear),
            .tags(.clear),
            .timeline(.clear)
        )
    }
}

private func loginEffect(_ api: APIProtocol, _ email: String, _ password: String) -> Effect<AppAction>
{
    api.loginUser(email: email, password: password)
        .map { user in .user(.setUser(user)) }
        .catch { error in Just(.setError(error)) }
        .eraseToEffect()
}

private func loadUserEffect(_ api: APIProtocol) -> Effect<AppAction>
{
    api.loadUser()
        .map { user in .user(.setUser(user)) }
        .catch { error in Just(.setError(error)) }
        .eraseToEffect()
}
