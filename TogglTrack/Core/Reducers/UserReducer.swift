//
//  UserReducer.swift
//  TogglWatch
//
//  Created by Juxhin Bakalli on 15/11/19.
//  Copyright © 2019 Toggl. All rights reserved.
//

import Foundation
import Combine

public var userReducer: Reducer<User?, UserAction, API> = Reducer { state, action, api in
    switch action {
        case .loadUser:
            return loadUserEffect(api)
        case let .setUser(user):
            state = user
            return .empty
    }
}

private func loadUserEffect(_ api: API) -> Effect<UserAction>
{
    return Effect {
        api.loadUser()
            .map { user in .setUser(user) }
            .catch { _ in Just(.setUser(nil)) }
            .eraseToAnyPublisher()
    }
}
