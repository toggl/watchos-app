//
//  Effect.swift
//  TogglWatch WatchKit Extension
//
//  Created by Ricardo Sánchez Sotres on 30/10/2019.
//  Copyright © 2019 Toggl. All rights reserved.
//

import Foundation
import Combine

public struct Effect<Action>: Publisher
{
    public typealias Output = Action
    public typealias Failure = Never
    
    let publisher: AnyPublisher<Output, Failure>
    
    fileprivate init(publisher: AnyPublisher<Output, Failure>)
    {
        self.publisher = publisher
    }
    
    public static var empty: Effect<Action> { Empty<Action, Never>().eraseToEffect() }
    
    public func receive<S>(subscriber: S) where S : Subscriber, Failure == S.Failure, Output == S.Input {
        self.publisher.receive(subscriber: subscriber)
    }
    
    public static func fromActions(_ actions: Action...) -> Effect<Action>
    {
        return Publishers.Sequence(sequence: actions)
            .eraseToEffect()
    }
}

extension Publisher where Failure == Never
{
    public func eraseToEffect() -> Effect<Output>
    {
        return Effect(publisher: self.eraseToAnyPublisher())
    }
}
