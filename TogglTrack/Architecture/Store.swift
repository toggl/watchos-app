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
    private var cancellables = Set<AnyCancellable>()
    private let environment: Environment
    
    public init(initialState: State, reducer: Reducer<State, Action, Environment>, environment: Environment)
    {
        self.reducer = reducer
        self.state = initialState
        self.environment = environment
    }
    
    public func send(_ action: Action)
    {
        let effect = self.reducer.run(&self.state, action, environment)
        
        effect
            .receive(on: DispatchQueue.main)
            .run()
            .sink(receiveValue: send)
            .store(in: &cancellables)
    }
    
    public func view<LocalState, LocalAction>(
        state toLocalState: @escaping (State) -> LocalState,
        action toGlobalAction: @escaping (LocalAction) -> Action
    ) -> Store<LocalState, LocalAction, Environment>
    {
        let localStore = Store<LocalState, LocalAction, Environment>(
            initialState: toLocalState(self.state),
            reducer: Reducer { localState, localAction, localEnvironment in
                self.send(toGlobalAction(localAction))
                localState = toLocalState(self.state)
                return .empty
            },
            environment: environment
        )
        
        self.$state
            .sink { [weak localStore] newState in
                localStore?.state = toLocalState(newState)
            }
            .store(in: &localStore.cancellables)
        
        return localStore
    }
}
