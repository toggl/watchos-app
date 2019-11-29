//
//  ObservableTimer.swift
//  TogglWatch WatchKit Extension
//
//  Created by Ricardo Sánchez Sotres on 28/11/2019.
//  Copyright © 2019 Toggl. All rights reserved.
//

import Foundation
import Combine

public class ObservableTimer
{
    public let currentTimePublisher = Timer.TimerPublisher(interval: 0.5, runLoop: .main, mode: .default)
    let cancellable: AnyCancellable?

    public init() {
        self.cancellable = currentTimePublisher.connect() as? AnyCancellable
    }

    deinit {
        self.cancellable?.cancel()
    }
}
