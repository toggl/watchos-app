//
//  RangeExtensions.swift
//  TogglWatch WatchKit Extension
//
//  Created by Ricardo Sánchez Sotres on 02/12/2019.
//  Copyright © 2019 Toggl. All rights reserved.
//

import Foundation

public extension ClosedRange {
    func clamp(_ value : Bound) -> Bound {
        return self.lowerBound > value ? self.lowerBound
            : self.upperBound < value ? self.upperBound
            : value
    }
}
