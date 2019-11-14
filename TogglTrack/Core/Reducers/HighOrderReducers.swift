//
//  HighOrderReducers.swift
//  TogglWatch WatchKit Extension
//
//  Created by Ricardo Sánchez Sotres on 07/11/2019.
//  Copyright © 2019 Toggl. All rights reserved.
//

import Foundation

public func logging<State, Action, Environment>(
    _ reducer: Reducer<State, Action, Environment>
) -> Reducer<State, Action, Environment> {
    return Reducer { state, action, environment in
        let effect = reducer.run(&state, action, environment)
        return Effect {
            print("Action: \(action)")
            return effect.run()
        }
    }
}
