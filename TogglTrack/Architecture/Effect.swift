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
    
    public static func concat(_ effects: Effect...) -> Effect<Action>
    {
        return effects.reduce(Empty().eraseToAnyPublisher()) { acc, effect in
            acc.append(effect).eraseToAnyPublisher()
        }
        .eraseToEffect()
    }
    
    public static func fireAndForget(work: @escaping () -> Void) -> Effect
    {
        return Deferred { () -> Empty<Output, Never> in
            work()
            return Empty(completeImmediately: true)
        }
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

extension Publisher where Output == Void
{
    public func eraseToEmptyEffect<Action>(catch transformError: @escaping (Error) -> Action) -> Effect<Action>
    {
        self.flatMap { _ in
            Empty().eraseToAnyPublisher()
        }
        .catch({ error in Just(transformError(error))})
        .eraseToEffect()
    }
}

extension Publisher
{
    public func toEffect<Action>(map mapOutput: @escaping (Output) -> Action, catch catchErrors: @escaping (Failure) -> Action) -> Effect<Action>
    {
        return self
            .map(mapOutput)
            .catch({ error in Just(catchErrors(error)) })
            .eraseToEffect()
    }
}
