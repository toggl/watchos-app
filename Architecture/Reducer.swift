//
//  Reducer.swift
//  TogglWatch WatchKit Extension
//
//  Created by Ricardo Sánchez Sotres on 30/10/2019.
//  Copyright © 2019 Toggl. All rights reserved.
//

import Foundation
import Combine

public struct Reducer<Value, Action, Environment>
{
    public let run: (inout Value, Action, Environment) -> Effect<Action>
    
    public init(_ run: @escaping (inout Value, Action, Environment) -> Effect<Action>)
    {
        self.run = run
    }    
}

public func combine<Value, Action, Environment>(
    _ reducers: Reducer<Value, Action, Environment>...
) -> Reducer<Value, Action, Environment> {
    return Reducer { value, action, environment in
        let effects = reducers.map{ $0.run(&value, action, environment)}
        return Effect<Action>.mergeMany(effects)
    }
}

public func pullback<LocalValue, GlobalValue, LocalAction, GlobalAction, GlobalEnvironment, LocalEnvironment>(
    _ reducer: Reducer<LocalValue, LocalAction, LocalEnvironment>,
    value: WritableKeyPath<GlobalValue, LocalValue>,
    action: WritableKeyPath<GlobalAction, LocalAction?>,
    environment: KeyPath<GlobalEnvironment, LocalEnvironment>
) -> Reducer<GlobalValue, GlobalAction, GlobalEnvironment> {
    return Reducer { globalValue, globalAction, globalEnvironment in
        guard let localAction = globalAction[keyPath: action] else { return .empty }
        let localEnvironment = globalEnvironment[keyPath: environment]
        return reducer
            .run(&globalValue[keyPath: value], localAction, localEnvironment)
            .map { localAction -> GlobalAction in
                var globalAction = globalAction
                globalAction[keyPath: action] = localAction
                return globalAction
            }
    }
}
