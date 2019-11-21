//
//  TimelineAction.swift
//  TogglWatch WatchKit Extension
//
//  Created by Ricardo Sánchez Sotres on 06/11/2019.
//  Copyright © 2019 Toggl. All rights reserved.
//

import Foundation

public enum TimeEntryAction
{
    case startEntry(String, Workspace)
    case stopRunningEntry
    case deleteEntry(id: Int)
    case setEntries([TimeEntry])
    case loadEntries
    case clear
    case setError(Error?)

}

extension TimeEntryAction: CustomStringConvertible
{
    public var description: String
    {
        switch self {
        case .setEntries(_):
            return "Set"
        case .startEntry(_, _):
            return "start"
        case .stopRunningEntry:
            return "stop"
        case .deleteEntry(_):
            return "delete"
        case .loadEntries:
            return "load"
        case .clear:
            return "clear"
        case let .setError(error):
            return "setError: \(error?.description ?? "nil")"
        }
    }
}
