//
//  AppReducerTests.swift
//  Toggl Track iOSTests
//
//  Created by Ricardo Sánchez Sotres on 25/11/2019.
//  Copyright © 2019 Toggl. All rights reserved.
//

import XCTest
import Combine
@testable import TogglTrack

class AppReducerTests: XCTestCase
{
    let reducer = appReducer
    var api = MockAPI()
    
    func testLoadAllSendsSetEntitiesForAllEntities()
    {
        let timeEntriesExpec = expectation(description: #function)
        let workspacesExpec = expectation(description: #function)
        let clientsExpec = expectation(description: #function)
        let projectsExpec = expectation(description: #function)
        let tasksExpec = expectation(description: #function)
        let tagsExpec = expectation(description: #function)
        
        let mockTEs = [
            TimeEntry.createNew(withDescription: "1", workspaceId: 1, billable: false, projectId: nil, taskId: nil, tagIds: []),
            TimeEntry.createNew(withDescription: "2", workspaceId: 2, billable: false, projectId: nil, taskId: nil, tagIds: []),
            TimeEntry.createNew(withDescription: "3", workspaceId: 3, billable: false, projectId: nil, taskId: nil, tagIds: [])
        ]
        api.returnedTimeEntries = mockTEs
        api.returnedWorkspaces = [Workspace(id: 0, name: "", admin: false)]
        api.returnedClients = [Client(id: 0, name: "", workspaceId: 0)]
        api.returnedProjects = [Project(id: 0, name: "", isPrivate: false, isActive: true, color: "", billable: false, workspaceId: 0, clientId: nil)]
        api.returnedTasks = [Task(id: 0, name: "", active: true, estimatedSeconds: 0, trackedSeconds: 0, projectId: 0, workspaceId: 0, userId: nil)]
        api.returnedTags = [Tag(id: 0, name: "", workspaceId: 0)]
        
        var appState = AppState()
        let appEnvironment = AppEnvironment(api: api, keychain: Keychain())
        let action = AppAction.loadAll
        let effect = reducer.run(&appState, action, appEnvironment)
        
        _ = effect
            .sink { appAction in
                switch appAction {
                    
                case let .timeEntries(entityAction):
                    switch entityAction {
                    case let .setEntities(entities):
                        XCTAssertEqual(mockTEs, entities, "TEs should be set after load")
                        timeEntriesExpec.fulfill()
                    default:
                        break
                    }
                    
                case let .workspaces(entityAction):
                    switch entityAction {
                    case .setEntities(_):
                        workspacesExpec.fulfill()
                    default:
                        break
                    }
                    
                case let .clients(entityAction):
                    switch entityAction {
                    case .setEntities(_):
                        clientsExpec.fulfill()
                    default:
                        break
                    }
                    
                case let .projects(entityAction):
                    switch entityAction {
                    case .setEntities(_):
                        projectsExpec.fulfill()
                    default:
                        break
                    }
                    
                case let .tasks(entityAction):
                    switch entityAction {
                    case .setEntities(_):
                        tasksExpec.fulfill()
                    default:
                        break
                    }
                    
                case let .tags(entityAction):
                    switch entityAction {
                    case .setEntities(_):
                        tagsExpec.fulfill()
                    default:
                        break
                    }
                    
                default:
                    break
                }
        }
        
        wait(for: [timeEntriesExpec, workspacesExpec, clientsExpec, projectsExpec, tasksExpec, tagsExpec], timeout: 1)
    }
}
