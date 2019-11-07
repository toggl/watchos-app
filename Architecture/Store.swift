//
//  Store.swift
//  TogglWatch WatchKit Extension
//
//  Created by Ricardo Sánchez Sotres on 15/10/2019.
//  Copyright © 2019 Toggl. All rights reserved.
//
import Combine
import SwiftUI

public final class Store<State, Action, Environment>: ObservableObject
{
    @Published public private(set) var state: State
    
    private let reducer: Reducer<State, Action, Environment>
    private var cancellable: Cancellable?
    private let environment: Environment
    
    public init(initialState: State, reducer: Reducer<State, Action, Environment>, environment: Environment) {
        self.reducer = reducer
        self.state = initialState
        self.environment = environment
    }
    
    public func send(_ action: Action) {
        let effect = self.reducer.run(&self.state, action, environment)
        
        _ = effect.run()
            .sink(receiveValue: send)
    }
    
    public func view<LocalState, LocalAction>(
        state toLocalState: @escaping (State) -> LocalState,
        action toGlobalAction: @escaping (LocalAction) -> Action
    ) -> Store<LocalState, LocalAction, Environment> {
        let localStore = Store<LocalState, LocalAction, Environment>(
            initialState: toLocalState(self.state),
            reducer: Reducer { localState, localAction, localEnvironment in
                self.send(toGlobalAction(localAction))
                localState = toLocalState(self.state)
                return .empty
            },
            environment: environment
        )
        localStore.cancellable = self.$state.sink { [weak localStore] newState in
            localStore?.state = toLocalState(newState)
        }
        return localStore
    }
}

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
