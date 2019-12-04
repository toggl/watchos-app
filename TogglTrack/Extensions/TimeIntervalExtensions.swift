//
//  TimeIntervalExtensions.swift
//  TogglWatch WatchKit Extension
//
//  Created by Ricardo Sánchez Sotres on 15/10/2019.
//  Copyright © 2019 Toggl. All rights reserved.
//

import Foundation

public extension TimeInterval
{
    func toIntervalString() -> String
    {
        let time = NSInteger(self)

        let seconds = time % 60
        let minutes = (time / 60) % 60
        let hours = (time / 3600)

        return String(format: "%0.1d:%0.2d:%0.2d ", hours, minutes, seconds)
    }
}
