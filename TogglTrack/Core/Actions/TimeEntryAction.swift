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
    case startEntry(String, Workspace)
    case stopRunningEntry
    case deleteEntry(Int)
    case entryDeleted(Int)
    case setError(Error?)
    case continueEntry(Int)
    case addTimeEntry(TimeEntry)
    case setEntries([TimeEntry])
    case clear
}

extension TimelineAction: CustomStringConvertible
{
    public var description: String
    {
        switch self {
        case .startEntry(_, _):
            return "start"
        case .stopRunningEntry:
            return "stop"
        case .deleteEntry(_):
            return "delete"
        case .entryDeleted(_):
            return "deleted"
        case let .setError(error):
            return "setError: \(error?.description ?? "nil")"
        case .continueEntry(_):
            return "continue"
        case .addTimeEntry(_):
            return "addTimeEntry"
        case .setEntries(_):
            return "setEntries"
        case .clear:
            return "clear"
        }
    }
}
