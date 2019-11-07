//
//  Store.swift
//  TogglWatch WatchKit Extension
//
//  Created by Ricardo Sánchez Sotres on 15/10/2019.
//  Copyright © 2019 Toggl. All rights reserved.
//
import Combine
import SwiftUI

public final class Store<Value, Action, Environment>: ObservableObject
{
    @Published public private(set) var value: Value
    
    private let reducer: Reducer<Value, Action, Environment>
    private var cancellable: Cancellable?
    private let environment: Environment
    
    public init(initialValue: Value, reducer: Reducer<Value, Action, Environment>, environment: Environment) {
        self.reducer = reducer
        self.value = initialValue
        self.environment = environment
    }
    
    public func send(_ action: Action) {
        let effect = self.reducer.run(&self.value, action, environment)
        
        _ = effect.run()
            .sink(receiveValue: send)
    }
    
    public func view<LocalValue, LocalAction>(
        value toLocalValue: @escaping (Value) -> LocalValue,
        action toGlobalAction: @escaping (LocalAction) -> Action
    ) -> Store<LocalValue, LocalAction, Environment> {
        let localStore = Store<LocalValue, LocalAction, Environment>(
            initialValue: toLocalValue(self.value),
            reducer: Reducer { localValue, localAction, localEnvironment in
                self.send(toGlobalAction(localAction))
                localValue = toLocalValue(self.value)
                return .empty
            },
            environment: environment
        )
        localStore.cancellable = self.$value.sink { [weak localStore] newValue in
            localStore?.value = toLocalValue(newValue)
        }
        return localStore
    }
}

public func logging<Value, Action, Environment>(
    _ reducer: Reducer<Value, Action, Environment>
) -> Reducer<Value, Action, Environment> {
    return Reducer { value, action, environment in
        let effect = reducer.run(&value, action, environment)
        return Effect {
            print("Action: \(action)")
            return effect.run()
        }
    }
}
