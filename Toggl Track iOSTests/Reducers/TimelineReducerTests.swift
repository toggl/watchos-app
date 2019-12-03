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
    var dateService = MockDateService()
    
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
        
        let effect = reducer.run(&timeEntryState, action, (api, dateService))
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
        _ = reducer.run(&timeEntryState, action, (api, dateService))
        
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
        
        let effect = reducer.run(&timeEntryState, action, (api, dateService))
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
        _ = reducer.run(&timeEntryState, action, (api, dateService))
        
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
        _ = reducer.run(&timeEntryState, action, (api, dateService))
        
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
        
        let effect = reducer.run(&timeEntryState, action, (api, dateService))
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
        
        _ = reducer.run(&timeEntryState, action, (api, dateService))
        
        XCTAssertTrue(timeEntryState.error != nil, "There should be an error in the state")
    }
    
    func testContinueEntrySendsStartTimeEntryEffect()
    {
        let didSendAction = expectation(description: #function)
        
        let workspace = Workspace(id: 1, name: "name", admin: false)
        let teDescription = "continueTE"
        let now = dateService.date
        let localTEStart = now.addingTimeInterval(-2000)
        let serverTEStart = now
        let localTE = TimeEntry.createNew(withDescription: teDescription, start: localTEStart, workspaceId: workspace.id)
        var timeEntryState: TimeEntriesState = ([localTE.id: localTE], nil, nil)
        let action = TimelineAction.continueEntry(localTE.id)
        let serverTE = TimeEntry.createNew(withDescription: teDescription, start: serverTEStart, workspaceId: workspace.id)
        api.returnStartedTimeEntry = serverTE
        
        let effect = reducer.run(&timeEntryState, action, (api, dateService))
        _ = effect
            .sink { action in
                guard case let TimelineAction.addTimeEntry(te) = action else { return }
                XCTAssertEqual(te.description, serverTE.description, "There should be new TE from the server")
                didSendAction.fulfill()
            }
        
        wait(for: [didSendAction], timeout: 1)
    }
    
    func testContinueEntrySendsErrorWhenItCantFindTheTimeEntryId()
    {
        let didSendAction = expectation(description: #function)
        
        let timelineState = TimelineState()
        var timeEntryState: TimeEntriesState = (timelineState.timeEntries, nil, nil)
        
        let action = TimelineAction.continueEntry(1)
        
        let effect = reducer.run(&timeEntryState, action, (api, dateService))
        _ = effect
            .sink { action in
                guard case let TimelineAction.setError(error as TimelineError) = action, error == .CantFindTimeEntry else { return }
                XCTAssertNotNil(error, "When it can't find timeEntry id to continue")
                didSendAction.fulfill()
            }
        
        wait(for: [didSendAction], timeout: 1)
    }
    
    func testAddTimeEntryAddsTimeEntryToState()
    {
        let teDescription = "To be stopped"
        let te = TimeEntry.createNew(withDescription: teDescription, workspaceId: 1, billable: false, projectId: nil, taskId: nil, tagIds: [])
        let timelineState = TimelineState()
        var timeEntryState: TimeEntriesState = (timelineState.timeEntries, nil, nil)
                
        XCTAssertNil(timeEntryState.runningTimeEntry, "There should not be a TE running")
        XCTAssertEqual(timeEntryState.timeEntries.values.count, 0, "There should not be any TE")
        
        let action = TimelineAction.addTimeEntry(te)
        _ = reducer.run(&timeEntryState, action, (api, dateService))
        
        XCTAssertNotNil(timeEntryState.runningTimeEntry, "There should be a TE running")
        XCTAssertEqual(timeEntryState.timeEntries.values.count, 1, "There should not be one TE")
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
