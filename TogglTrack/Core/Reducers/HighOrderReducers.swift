//
//  HighOrderReducers.swift
//  TogglWatch WatchKit Extension
//
//  Created by Ricardo Sánchez Sotres on 07/11/2019.
//  Copyright © 2019 Toggl. All rights reserved.
//

import Foundation
import Combine

public func logging<State, Action, Environment>(
    _ reducer: Reducer<State, Action, Environment, Action>
) -> Reducer<State, Action, Environment, Action> {
    return Reducer { state, action, environment in
        print("Action: \(action)")
        return reducer.run(&state, action, environment)
    }
}
