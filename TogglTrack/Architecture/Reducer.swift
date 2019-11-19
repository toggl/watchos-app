//
//  Reducer.swift
//  TogglWatch WatchKit Extension
//
//  Created by Ricardo Sánchez Sotres on 30/10/2019.
//  Copyright © 2019 Toggl. All rights reserved.
//

import Foundation
import Combine

public struct Reducer<State, Action, Environment>
{
    public let run: (inout State, Action, Environment) -> Effect<Action>
    
    public init(_ run: @escaping (inout State, Action, Environment) -> Effect<Action>)
    {
        self.run = run
    }    
}

public func combine<State, Action, Environment>(
    _ reducers: Reducer<State, Action, Environment>...
) -> Reducer<State, Action, Environment> {
    return Reducer { state, action, environment in
        let effects = reducers.map{ $0.run(&state, action, environment)}
        return Publishers.MergeMany(effects).eraseToEffect()
    }
}

public func pullback<LocalState, GlobalState, LocalAction, GlobalAction, GlobalEnvironment, LocalEnvironment>(
    _ reducer: Reducer<LocalState, LocalAction, LocalEnvironment>,
    state: WritableKeyPath<GlobalState, LocalState>,
    action: WritableKeyPath<GlobalAction, LocalAction?>,
    environment: KeyPath<GlobalEnvironment, LocalEnvironment>
) -> Reducer<GlobalState, GlobalAction, GlobalEnvironment> {
    return Reducer { globalState, globalAction, globalEnvironment in
        guard let localAction = globalAction[keyPath: action] else { return .empty }
        let localEnvironment = globalEnvironment[keyPath: environment]
        return reducer
            .run(&globalState[keyPath: state], localAction, localEnvironment)
            .map { localAction -> GlobalAction in
                var globalAction = globalAction
                globalAction[keyPath: action] = localAction
                return globalAction
            }
            .eraseToEffect()
    }
}
