//
//  Effect.swift
//  TogglWatch WatchKit Extension
//
//  Created by Ricardo Sánchez Sotres on 30/10/2019.
//  Copyright © 2019 Toggl. All rights reserved.
//

import Foundation
import Combine

public struct Effect<Action>
{
    public let run: () -> AnyPublisher<Action, Never>
    
    public init(_ run: @escaping () -> AnyPublisher<Action, Never>)
    {
        self.run = run
    }
        
    public static var empty: Self { Effect({ return Empty<Action, Never>().eraseToAnyPublisher() }) }
    
    public static func fromActions(actions: Action...) -> Self
    {
        return Effect { Publishers.Sequence(sequence: actions).eraseToAnyPublisher() }
    }
    
    public func map<B>(_ f: @escaping (Action) -> B) -> Effect<B>
    {
        return Effect<B> {
            return self.run()
                .map(f)
                .eraseToAnyPublisher()
        }
    }
    
    public func flatMap<B>(_ f: @escaping (Action) -> Effect<B>) -> Effect<B>
    {
        return Effect<B> {
            return self.run()
                .flatMap{ action in f(action).run() }
                .eraseToAnyPublisher()
        }
    }
    
    public static func mergeMany<A>(_ effects: [Effect<A>]) -> Effect<A>
    {
        return Effect<A> {
            Publishers.MergeMany(effects.map({ $0.run() }))
                .eraseToAnyPublisher()
        }
    }

    public static func zip<A, B>(_ a: Effect<A>, _ b: Effect<B>) -> Effect<(A, B)>
    {
        return Effect<(A, B)> {
            return a.run()
                .zip(b.run())
                .eraseToAnyPublisher()
        }
    }
}
