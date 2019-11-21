//
//  Errors.swift
//  TogglWatch WatchKit Extension
//
//  Created by Ricardo Sánchez Sotres on 29/10/2019.
//  Copyright © 2019 Toggl. All rights reserved.
//

import Foundation

public struct NoTokenError: Error
{
    public init() { }
}

public enum NetworkingError: Error
{
    case noData
    case wrongStatus(Int, HTTPURLResponse?)
    case unknown
}
