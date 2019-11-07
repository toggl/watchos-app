//
//  Errors.swift
//  TogglWatch WatchKit Extension
//
//  Created by Ricardo Sánchez Sotres on 29/10/2019.
//  Copyright © 2019 Toggl. All rights reserved.
//

import Foundation

public struct NoDataError: Error {
    public init() { }
}

public struct UnknownError: Error {
    public init() { }
}

public struct WrongStatusCodeError: Error {
    public let statusCode: Int
    public let response: HTTPURLResponse?
    public init(statusCode: Int, response: HTTPURLResponse?) {
        self.statusCode = statusCode
        self.response = response
    }
}
