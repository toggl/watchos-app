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
    
    private let reducer: Reducer<State, Action, Environment, Action>
    private var cancellables = Set<AnyCancellable>()
    private let environment: Environment
    
    public init(initialState: State, reducer: Reducer<State, Action, Environment, Action>, environment: Environment)
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
            .sink(receiveValue: send)
            .store(in: &cancellables)
    }
}
