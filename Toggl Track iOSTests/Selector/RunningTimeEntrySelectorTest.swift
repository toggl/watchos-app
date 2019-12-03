//
//  RunningTimeEntrySelector.swift
//  Toggl Track iOSTests
//
//  Created by Juxhin Bakalli on 3/12/19.
//  Copyright © 2019 Toggl. All rights reserved.
//

import XCTest
import Combine
@testable import TogglTrack

class RunningTimeEntrySelector: XCTestCase
{
    func testSelectorReturnsTheRunninTimeEntry()
    {
        var timelineState = TimelineState()
        let teDescription = "running TE"
        let te = TimeEntry.createNew(withDescription: teDescription, workspaceId: 1, billable: false, projectId: nil, taskId: nil, tagIds: [])
        timelineState.timeEntries = [te.id: te]
        timelineState.runningTimeEntryID = te.id
                
        XCTAssertEqual(runningTimeEntrySelector(timelineState), te, "Should return the running time entry")
    }
    
    func testSelectorReturnsNilWhenThereIsNoRunningTE()
    {
        var timelineState = TimelineState()
        let teDescription = "running TE"
        let te = TimeEntry.createNew(withDescription: teDescription, workspaceId: 1, billable: false, projectId: nil, taskId: nil, tagIds: [])
        timelineState.timeEntries = [te.id: te]
                
        XCTAssertNil(runningTimeEntrySelector(timelineState), "Should return nil")
    }
    
    func testSelectorReturnsTheUpdatedRunningTE()
    {
        var timelineState = TimelineState()
        let teDescription = "running TE"
        var te = TimeEntry.createNew(withDescription: teDescription, workspaceId: 1, billable: false, projectId: nil, taskId: nil, tagIds: [])
        te.id = 1
        timelineState.timeEntries = [te.id: te]
        timelineState.runningTimeEntryID = te.id
        
        XCTAssertNotNil(runningTimeEntrySelector(timelineState), "Should not be nil")
        
        te.description = "new running TE description"
        timelineState.timeEntries[te.id] = te
        
        XCTAssertEqual(runningTimeEntrySelector(timelineState)?.description, te.description, "Should return the updated running time entry")
    }
}
