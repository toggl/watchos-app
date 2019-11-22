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
    
    func testStartEntryAddsNewTimeEntryToState()
    {
        let timelineState = TimelineState()
        var timeEntryState: TimeEntriesState = (timelineState.timeEntries, nil)
        let workspace = Workspace(id: 1, name: "name", admin: false)
        let teDescription = "newTE"
        let action = TimeEntryAction.startEntry(teDescription, workspace)
        
        _ = reducer.run(&timeEntryState, action, api)
        
        let newTEs = timeEntryState.timeEntries
            .byId
            .filter { (id, te) in te.description == teDescription }
        
        XCTAssertEqual(newTEs.count, 1, "There should be only 1 new TE")
        
        let teID = newTEs.first!.key
        let sortedTeID = timeEntryState.timeEntries
            .sorted
            .filter{ $0 == teID }
        
        XCTAssertEqual(sortedTeID.count, 1, "There should be only 1 new TE ID")
    }
    
    func testStopRunningEntryStopsTimeEntryInState()
    {
        let timelineState = TimelineState()
        var timeEntryState: TimeEntriesState = (timelineState.timeEntries, nil)
        let teDescription = "To be stopped"
        let te = TimeEntry.createNew(withDescription: teDescription, workspaceId: 1, billable: false, projectId: nil, taskId: nil, tagIds: [])
        
        timeEntryState.timeEntries.byId[te.id] = te
        timeEntryState.timeEntries.sorted.insert(te.id, at: 0)
        
        let action = TimeEntryAction.stopRunningEntry
        
        _ = reducer.run(&timeEntryState, action, api)
        
        let stopedTEs = timeEntryState.timeEntries
            .byId
            .filter { (id, te) in te.description == teDescription && te.duration != 0 }
        
        XCTAssertEqual(stopedTEs.count, 1, "There should be only 1 TE with desired description and non 0 duration")
    }
    
    func testStopRunningEntrySendsErrorWhenItCantFindTheTimeEntryId()
    {
        let didSendAction = expectation(description: #function)
        
        let timelineState = TimelineState()
        var timeEntryState: TimeEntriesState = (timelineState.timeEntries, nil)
        
        let action = TimeEntryAction.stopRunningEntry
        
        let effect = reducer.run(&timeEntryState, action, api)
        _ = effect
            .sink { action in
                guard case let TimeEntryAction.setError(error as TimelineError) = action, error == .CantFindRunningTimeEntryId else { return }
                XCTAssertNotNil(error, "When it can't find timeEntry id to continue")
                didSendAction.fulfill()
            }
        
        wait(for: [didSendAction], timeout: 1)
    }
    
    func testDeleteEntryRemovesTimeEntryFromState()
    {
        let timelineState = TimelineState()
        var timeEntryState: TimeEntriesState = (timelineState.timeEntries, nil)
        let teDescription = "To be deleted"
        let te = TimeEntry.createNew(withDescription: teDescription, workspaceId: 1, billable: false, projectId: nil, taskId: nil, tagIds: [])
        
        timeEntryState.timeEntries.byId[te.id] = te
        timeEntryState.timeEntries.sorted.insert(te.id, at: 0)
        
        let action = TimeEntryAction.deleteEntry(id: te.id)
        
        var newTEs = timeEntryState.timeEntries
            .byId
            .filter { (id, te) in te.description == teDescription }
        
        XCTAssertEqual(newTEs.count, 1, "There should be only 1 TE")
        
        let teID = newTEs.first!.key
        var sortedTeID = timeEntryState.timeEntries
            .sorted
            .filter{ $0 == teID }
        
        XCTAssertEqual(sortedTeID.count, 1, "There should be only 1 TE")
        
        _ = reducer.run(&timeEntryState, action, api)
        
        newTEs = timeEntryState.timeEntries
            .byId
            .filter { (id, te) in te.description == teDescription }
        
        XCTAssertEqual(newTEs.count, 0, "There should not be any TE")
        
        sortedTeID = timeEntryState.timeEntries
            .sorted
            .filter{ $0 == teID }
        
        XCTAssertEqual(sortedTeID.count, 0, "There should not be any TE")
    }
    
    func testDeleteEntrySendsErrorWhenItCantFindTheTimeEntryIdToDelete()
    {
        let didSendAction = expectation(description: #function)
        
        let timelineState = TimelineState()
        var timeEntryState: TimeEntriesState = (timelineState.timeEntries, nil)
        
        let action = TimeEntryAction.deleteEntry(id: 1)
        
        let effect = reducer.run(&timeEntryState, action, api)
        _ = effect
            .sink { action in
                guard case let TimeEntryAction.setError(error as TimelineError) = action, error == .CantFindIndexOfTimeEntryToDelete else { return }
                XCTAssertNotNil(error, "When it can't find timeEntry id to delete")
                didSendAction.fulfill()
            }
        
        wait(for: [didSendAction], timeout: 1)
    }
    
    func testLoadEntriesSendsSetEntriesActionWhenSucceeds()
    {
        let didSendAction = expectation(description: #function)
        
        let timelineState = TimelineState()
        var timeEntryState: TimeEntriesState = (timelineState.timeEntries, nil)
        let mockTEs = [
            TimeEntry.createNew(withDescription: "1", workspaceId: 1, billable: false, projectId: nil, taskId: nil, tagIds: []),
            TimeEntry.createNew(withDescription: "2", workspaceId: 2, billable: false, projectId: nil, taskId: nil, tagIds: []),
            TimeEntry.createNew(withDescription: "3", workspaceId: 3, billable: false, projectId: nil, taskId: nil, tagIds: [])
        ]
        api.returnedTimeEntries = mockTEs
        
        let action = TimeEntryAction.loadEntries
        
        let effect = reducer.run(&timeEntryState, action, api)
        _ = effect
            .sink { timelineAction in
                guard case let TimeEntryAction.setEntries(tes) = timelineAction else { return }
                XCTAssertEqual(mockTEs, tes, "TEs should be set after load")
                didSendAction.fulfill()
            }
        
        wait(for: [didSendAction], timeout: 1)
    }
    
    func testSetEntriesSendsTimeEntriesToState()
    {
        let timelineState = TimelineState()
        var timeEntryState: TimeEntriesState = (timelineState.timeEntries, nil)
        let mockTEs = [
            TimeEntry.createNew(withDescription: "1", workspaceId: 1, billable: false, projectId: nil, taskId: nil, tagIds: []).withStartTime(newStart: Date()),
            TimeEntry.createNew(withDescription: "2", workspaceId: 2, billable: false, projectId: nil, taskId: nil, tagIds: []).withStartTime(newStart: Date().advanced(by: -1)),
            TimeEntry.createNew(withDescription: "3", workspaceId: 3, billable: false, projectId: nil, taskId: nil, tagIds: []).withStartTime(newStart: Date().advanced(by: -2))
        ]
        
        let action = TimeEntryAction.setEntries(mockTEs)
        
        _ = reducer.run(&timeEntryState, action, api)
        
        let stateTEs = timeEntryState.timeEntries.sorted.map { timeEntryState.timeEntries.byId[$0] }
        
        XCTAssertEqual(stateTEs, mockTEs, "TEs should be set in the state")
    }
    
    func testClearRemovesAllTimeEntries()
    {
        let timelineState = TimelineState()
        var timeEntryState: TimeEntriesState = (timelineState.timeEntries, nil)
        let mockTEs = [
            TimeEntry.createNew(withDescription: "1", workspaceId: 1, billable: false, projectId: nil, taskId: nil, tagIds: []).withStartTime(newStart: Date()),
            TimeEntry.createNew(withDescription: "2", workspaceId: 2, billable: false, projectId: nil, taskId: nil, tagIds: []).withStartTime(newStart: Date().advanced(by: -1)),
            TimeEntry.createNew(withDescription: "3", workspaceId: 3, billable: false, projectId: nil, taskId: nil, tagIds: []).withStartTime(newStart: Date().advanced(by: -2))
        ]
        
        mockTEs.forEach({ te in
            timeEntryState.timeEntries.byId[te.id] = te
            timeEntryState.timeEntries.sorted.append(te.id)
        })
        
        let action = TimeEntryAction.clear
        
        var newTEsCount = timeEntryState.timeEntries
            .byId
            .values
            .count
        
        XCTAssertEqual(newTEsCount, 3, "There should be only 3 TE")
        
        var sortedTeIDCount = timeEntryState.timeEntries
            .sorted
            .count
        
        XCTAssertEqual(sortedTeIDCount, 3, "There should be only 3 TE IDs")
        
        _ = reducer.run(&timeEntryState, action, api)
        
        newTEsCount = timeEntryState.timeEntries
            .byId
            .values
            .count
        
        XCTAssertEqual(newTEsCount, 0, "There should not be any TE")
        
        sortedTeIDCount = timeEntryState.timeEntries
            .sorted
            .count
        
        XCTAssertEqual(sortedTeIDCount, 0, "There should not be any TE ID")
    }
    
    func testSetErrorSendsTheErrorToTheState()
    {
        let timelineState = TimelineState()
        var timeEntryState: TimeEntriesState = (timelineState.timeEntries, nil)
        let error = TimelineError.CantFindIndexOfTimeEntryToDelete
        let action = TimeEntryAction.setError(error)
        
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
