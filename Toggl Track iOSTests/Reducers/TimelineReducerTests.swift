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
    
    func testDeleteEntrySendsRequestToAPI()
    {
        let teDescription = "To be deleted"
        let te = TimeEntry.createNew(withDescription: teDescription, workspaceId: 1, billable: false, projectId: nil, taskId: nil, tagIds: [])
        
        var timeEntryState: TimeEntriesState = ([te.id: te], nil, [:])
        
        let action = TimelineAction.deleteEntry(te.id)
        _ = reducer.run(&timeEntryState, action, (api, dateService))
        
        XCTAssertTrue(api.deleteCalled, "Should call delete on API")
    }
    
    func testDeletedEntryRemovesTimeEntryFromState()
    {
        let teDescription = "To be deleted"
        let te = TimeEntry.createNew(withDescription: teDescription, workspaceId: 1, billable: false, projectId: nil, taskId: nil, tagIds: [])
        
        var timeEntryState: TimeEntriesState = ([te.id: te], nil, [:])
        
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
        var timeEntryState: TimeEntriesState = (timelineState.timeEntries, nil, [:])
        
        let action = TimelineAction.deleteEntry(1)
        
        let effect = reducer.run(&timeEntryState, action, (api, dateService))
        _ = effect
            .sink { action in
                guard case let .setError(error as TimelineError) = action, error == .CantFindTimeEntry else { return }
                XCTAssertNotNil(error, "When it can't find timeEntry id to delete")
                didSendAction.fulfill()
            }
        
        wait(for: [didSendAction], timeout: 1)
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
        var timeEntryState: TimeEntriesState = ([localTE.id: localTE], nil, [:])
        let action = TimelineAction.continueEntry(localTE.id)
        let serverTE = TimeEntry.createNew(withDescription: teDescription, start: serverTEStart, workspaceId: workspace.id)
        api.returnStartedTimeEntry = serverTE
        
        let effect = reducer.run(&timeEntryState, action, (api, dateService))
        _ = effect
            .sink { action in
                guard case let .timeline(.startTimeEntry(te)) = action else { return }
                XCTAssertEqual(te.description, serverTE.description, "There should be new TE from the server")
                didSendAction.fulfill()
            }
        
        wait(for: [didSendAction], timeout: 1)
    }
    
    func testContinueEntrySendsErrorWhenItCantFindTheTimeEntryId()
    {
        let didSendAction = expectation(description: #function)
        
        let timelineState = TimelineState()
        var timeEntryState: TimeEntriesState = (timelineState.timeEntries, nil, [:])
        
        let action = TimelineAction.continueEntry(1)
        
        let effect = reducer.run(&timeEntryState, action, (api, dateService))
        _ = effect
            .sink { action in
                guard case let .setError(error as TimelineError) = action, error == .CantFindTimeEntry else { return }
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
        var timeEntryState: TimeEntriesState = (timelineState.timeEntries, nil, [:])
                
        XCTAssertNil(timeEntryState.runningTimeEntry, "There should not be a TE running")
        XCTAssertEqual(timeEntryState.timeEntries.values.count, 0, "There should not be any TE")
        
        let action = TimelineAction.startTimeEntry(te)
        _ = reducer.run(&timeEntryState, action, (api, dateService))
        
        XCTAssertNotNil(timeEntryState.runningTimeEntry, "There should be a TE running")
        XCTAssertEqual(timeEntryState.timeEntries.values.count, 1, "There should not be one TE")
    }
    
    func testStopTimeEntryReturnsErrorIfTheresNoEntryRunning()
    {
        let didSendAction = expectation(description: #function)

        var timeEntryState: TimeEntriesState = ([:], nil, [:])
        let action = TimelineAction.stopRunningEntry
       
        let effect = reducer.run(&timeEntryState, action, (api, dateService))
        _ = effect
            .sink { action in
                guard case let .setError(error as TimelineError) = action, error == .NoRunningEntry else { return }
                XCTAssertNotNil(error, "No running entry should return an error")
                didSendAction.fulfill()
            }

        wait(for: [didSendAction], timeout: 1)
    }
    
    func testStopTimeEntryReturnsErrorIfCantFindRunningEntry()
    {
        let didSendAction = expectation(description: #function)

        let runningEntryId = 1234
        var timeEntryState: TimeEntriesState = ([:], runningEntryId, [:])
        let action = TimelineAction.stopRunningEntry
        
        let effect = reducer.run(&timeEntryState, action, (api, dateService))
        _ = effect
            .sink { action in
                guard case let .setError(error as TimelineError) = action, error == .NoRunningEntry else { return }
                XCTAssertNotNil(error, "No running entry should return an error")
                didSendAction.fulfill()
            }

        wait(for: [didSendAction], timeout: 1)
    }
    
    func testStopRunningEntryCallsAPIWithAppropriateEntry()
    {
        let duration: TimeInterval = 8000
        let now = Date()
        dateService.currentDate = now
        
        var te = TimeEntry.createNew(withDescription: "", workspaceId: 1, billable: false, projectId: nil, taskId: nil, tagIds: [])
        te.start = now.addingTimeInterval(-duration)
        
        var timeEntryState: TimeEntriesState = ([te.id:te], te.id, [:])
        let action = TimelineAction.stopRunningEntry
        
        _ = reducer.run(&timeEntryState, action, (api, dateService))

        XCTAssertNotNil(self.api.updatedTimeEntry, "Should have called update in the API")
        XCTAssertEqual(self.api.updatedTimeEntry?.duration, duration, "Should have called update in the API")
    }
    
    func testStopRunningEntryReturnsTheCorrectEffect()
    {
        let didSendAction = expectation(description: #function)

        let duration: TimeInterval = 8000
        let now = Date()
        dateService.currentDate = now
        
        var te = TimeEntry.createNew(withDescription: "", workspaceId: 1, billable: false, projectId: nil, taskId: nil, tagIds: [])
        te.start = now.addingTimeInterval(-duration)
        
        var stoppedTE = te
        stoppedTE.duration = duration
        api.returnUpdatedTimeEntry = stoppedTE
        
        var timeEntryState: TimeEntriesState = ([te.id:te], te.id, [:])
        let action = TimelineAction.stopRunningEntry
        
        let effect = reducer.run(&timeEntryState, action, (api, dateService))
        _ = effect
            .sink { action in
                print(action)
                guard case let .timeline(.entryUpdated(timeEntry)) = action else { return }
                XCTAssertEqual(timeEntry.id, te.id, "Effect not carrying the correct TE")
                didSendAction.fulfill()
            }

        wait(for: [didSendAction], timeout: 1)    }
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
