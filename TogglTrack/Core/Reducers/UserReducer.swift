//
//  UserReducer.swift
//  TogglWatch
//
//  Created by Juxhin Bakalli on 15/11/19.
//  Copyright © 2019 Toggl. All rights reserved.
//

import Foundation
import Combine

public var userReducer: Reducer<UserState, UserAction, API> = Reducer { state, action, api in
    switch action {
    case let .login(email, password):
        return loginEffect(api, email, password)
    case let .setUser(user):
        state.user = user
        return .empty
    case let .setError(error):
        state.error = error
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
