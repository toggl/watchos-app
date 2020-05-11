//
//  PublisherExtensions.swift
//  TogglWatch WatchKit Extension
//
//  Created by Ricardo Sánchez Sotres on 19/12/2019.
//  Copyright © 2019 Toggl. All rights reserved.
//

import Foundation
import Combine

extension Publisher where Failure == Error
{
    func tryFlatMap<B>(_ f: @escaping (Output) throws -> AnyPublisher<B, Failure>) -> AnyPublisher<B, Failure>
    {
        return self.tryMap(f)
            .flatMap{ $0 }
            .eraseToAnyPublisher()
    }
}

extension Publisher {
    func retryWithDelay<T, E>(retries: Int = 3, delay: Int = 4)
        -> Publishers.Catch<Self, AnyPublisher<T, E>> where T == Self.Output, E == Self.Failure
    {
        return self.catch { error -> AnyPublisher<T, E> in
            return Publishers.Delay(
                upstream: self,
                interval: .seconds(delay),
                tolerance: 1,
                scheduler: DispatchQueue.global()
            )
            .retry(retries)
            .eraseToAnyPublisher()
        }
    }
}
