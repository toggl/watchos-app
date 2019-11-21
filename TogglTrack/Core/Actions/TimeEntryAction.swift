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
    case setError(Error?)
}
