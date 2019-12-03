//
//  MockDateService.swift
//  Toggl Track iOSTests
//
//  Created by Ricardo Sánchez Sotres on 03/12/2019.
//  Copyright © 2019 Toggl. All rights reserved.
//

import Foundation
@testable import TogglTrack

class MockDateService: DateServiceProtocol
{
    var currentDate: Date = Date()
    
    var date: Date {
        return currentDate
    }
}
