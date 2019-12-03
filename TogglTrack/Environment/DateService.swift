//
//  DateService.swift
//  TogglWatch WatchKit Extension
//
//  Created by Ricardo Sánchez Sotres on 03/12/2019.
//  Copyright © 2019 Toggl. All rights reserved.
//

import Foundation

public protocol DateServiceProtocol
{
    var date: Date { get }
}

public class DateService: DateServiceProtocol
{
    public var date: Date {
        return Date()
    }
    
    public init() {}
}
