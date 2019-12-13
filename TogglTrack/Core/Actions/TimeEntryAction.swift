//
//  TimelineAction.swift
//  TogglWatch WatchKit Extension
//
//  Created by Ricardo Sánchez Sotres on 06/11/2019.
//  Copyright © 2019 Toggl. All rights reserved.
//

import Foundation

public enum TimelineAction
{
    case stopRunningEntry
    case deleteEntry(Int)
    case entryDeleted(Int)
    case continueEntry(Int)
    case addTimeEntry(TimeEntry)
    case setEntries([TimeEntry])
    case entryUpdated(TimeEntry)
    case clear
}

extension TimelineAction: CustomStringConvertible
{
    public var description: String
    {
        switch self {
        case .stopRunningEntry:
            return "stopRunningTimeEntry"
        case .deleteEntry(_):
            return "delete"
        case .entryDeleted(_):
            return "deleted"
        case .continueEntry(_):
            return "continue"
        case .addTimeEntry(_):
            return "addTimeEntry"
        case .setEntries(_):
            return "setEntries"
        case .entryUpdated(_):
            return "entryUpdated"
        case .clear:
            return "clear"
        }
    }
}
