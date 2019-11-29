//
//  TimelineReducerTests.swift
//  Toggl Track iOSTests
//
//  Created by Juxhin Bakalli on 20/11/19.
//  Copyright © 2019 Toggl. All rights reserved.
//

import XCTest
import Combine
@testable import TogglTrack

class TimelineReducerTests: XCTestCase
{
    var reducer = timelineReducer
    var api = MockAPI()
    
    func testStartEntryReturnsStartTimeEntryEffect()
    {
        let didSendAction = expectation(description: #function)
        
        let timelineState = TimelineState()
        var timeEntryState: TimeEntriesState = (timelineState.timeEntries, nil, nil)
        let workspace = Workspace(id: 1, name: "name", admin: false)
        let teDescription = "newTE"
        let action = TimelineAction.startEntry(teDescription, workspace)
        let serverTE = TimeEntry.createNew(withDescription: teDescription, workspaceId: workspace.id)
        api.returnStartedTimeEntry = serverTE
        
        let effect = reducer.run(&timeEntryState, action, api)
        _ = effect
            .sink { action in
                guard case let TimelineAction.addTimeEntry(te) = action else { return }
                XCTAssertEqual(te.description, serverTE.description, "There should be new TE from the server")
                didSendAction.fulfill()
            }
        
        wait(for: [didSendAction], timeout: 1)
    }
    
    func testStopRunningEntryStopsTimeEntryInState()
    {
        let teDescription = "To be stopped"
        let te = TimeEntry.createNew(withDescription: teDescription, workspaceId: 1, billable: false, projectId: nil, taskId: nil, tagIds: [])
        var timeEntryState: TimeEntriesState = ([te.id: te], te.id, nil)
                
        XCTAssertNotNil(timeEntryState.runningTimeEntry, "There should be a TE running")
        
        let action = TimelineAction.stopRunningEntry
        _ = reducer.run(&timeEntryState, action, api)
        
        let stopedTEs = timeEntryState.timeEntries
            .filter { (id, te) in te.description == teDescription && te.duration != 0 }
        
        XCTAssertEqual(stopedTEs.count, 1, "There should be only 1 TE with desired description and non 0 duration")
        XCTAssertNil(timeEntryState.runningTimeEntry, "There should not be a TE running")
    }
    
    func testStopRunningEntrySendsErrorWhenItCantFindTheTimeEntryId()
    {
        let didSendAction = expectation(description: #function)
        
        let timelineState = TimelineState()
        var timeEntryState: TimeEntriesState = (timelineState.timeEntries, nil, nil)
        
        let action = TimelineAction.stopRunningEntry
        
        let effect = reducer.run(&timeEntryState, action, api)
        _ = effect
            .sink { action in
                guard case let TimelineAction.setError(error as TimelineError) = action, error == .CantFindTimeEntry else { return }
                XCTAssertNotNil(error, "When it can't find timeEntry id to continue")
                didSendAction.fulfill()
            }
        
        wait(for: [didSendAction], timeout: 1)
    }
    
    func testDeleteEntrySendsRequestToAPI()
    {
        let teDescription = "To be deleted"
        let te = TimeEntry.createNew(withDescription: teDescription, workspaceId: 1, billable: false, projectId: nil, taskId: nil, tagIds: [])
        
        var timeEntryState: TimeEntriesState = ([te.id: te], nil, nil)
        
        let action = TimelineAction.deleteEntry(te.id)
        _ = reducer.run(&timeEntryState, action, api)
        
        XCTAssertTrue(api.deleteCalled, "Should call delete on API")
    }
    
    func testDeletedEntryRemovesTimeEntryFromState()
    {
        let teDescription = "To be deleted"
        let te = TimeEntry.createNew(withDescription: teDescription, workspaceId: 1, billable: false, projectId: nil, taskId: nil, tagIds: [])
        
        var timeEntryState: TimeEntriesState = ([te.id: te], nil, nil)
        
        var newTEs = timeEntryState.timeEntries
            .filter { (id, te) in te.description == teDescription }
        
        XCTAssertEqual(newTEs.count, 1, "There should be only 1 TE")
        
        let action = TimelineAction.entryDeleted(te.id)
        _ = reducer.run(&timeEntryState, action, api)
        
        newTEs = timeEntryState.timeEntries
            .filter { (id, te) in te.description == teDescription }
        
        XCTAssertEqual(newTEs.count, 0, "There should not be any TE")
    }
    
    func testDeleteEntrySendsErrorWhenItCantFindTheTimeEntryIdToDelete()
    {
        let didSendAction = expectation(description: #function)
        
        let timelineState = TimelineState()
        var timeEntryState: TimeEntriesState = (timelineState.timeEntries, nil, nil)
        
        let action = TimelineAction.deleteEntry(1)
        
        let effect = reducer.run(&timeEntryState, action, api)
        _ = effect
            .sink { action in
                guard case let TimelineAction.setError(error as TimelineError) = action, error == .CantFindTimeEntry else { return }
                XCTAssertNotNil(error, "When it can't find timeEntry id to delete")
                didSendAction.fulfill()
            }
        
        wait(for: [didSendAction], timeout: 1)
    }
    
    func testSetErrorSendsTheErrorToTheState()
    {
        let timelineState = TimelineState()
        var timeEntryState: TimeEntriesState = (timelineState.timeEntries, nil, nil)
        let error = TimelineError.CantFindTimeEntry
        let action = TimelineAction.setError(error)
        
        XCTAssertTrue(timeEntryState.error == nil, "There should not be an error in the state")
        
        _ = reducer.run(&timeEntryState, action, api)
        
        XCTAssertTrue(timeEntryState.error != nil, "There should be an error in the state")
    }
}

extension TimeEntry
{
    public func withStartTime(newStart: Date) -> TimeEntry
    {
        return TimeEntry(
            id: self.id,
            description: self.description,
            start: newStart,
            duration: self.duration,
            billable: self.billable,
            workspaceId: self.workspaceId,
            projectId: self.projectId,
            taskId: self.taskId,
            tagIds: self.tagIds
        )
    }
}
