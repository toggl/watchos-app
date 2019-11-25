//
//  EntityReducerTests.swift
//  Toggl Track iOSTests
//
//  Created by Ricardo Sánchez Sotres on 25/11/2019.
//  Copyright © 2019 Toggl. All rights reserved.
//

import XCTest
import Combine
@testable import TogglTrack

struct MockEntity: Identifiable
{
    var id: Int
    var name: String
}

class EntityReducerTests: XCTestCase
{
    var api = MockAPI()
    
    func testSetEntriesSendsTimeEntriesToStateUnsorted()
    {
        let reducer: Reducer<[MockEntity.ID: MockEntity], EntityAction<MockEntity>, APIProtocol> = createEntityReducer()

        var entityState = [MockEntity.ID: MockEntity]()
        
        let entities = [
            MockEntity(id: 0, name: "0"),
            MockEntity(id: 1, name: "1"),
            MockEntity(id: 2, name: "2")
        ]
        
        let action = EntityAction<MockEntity>.setEntities(entities)
        
        _ = reducer.run(&entityState, action, api)
        
        XCTAssertEqual(entityState.count, entities.count, "Entities should be set in the state")
    }
    
    func testClearRemovesAllTimeEntries()
    {
        let reducer: Reducer<[MockEntity.ID: MockEntity], EntityAction<MockEntity>, APIProtocol> = createEntityReducer()

        var entityState = [MockEntity.ID: MockEntity]()

        let entities = [
            MockEntity(id: 0, name: "0"),
            MockEntity(id: 1, name: "1"),
            MockEntity(id: 2, name: "2")
        ]
        
        entities.forEach({ te in
            entityState[te.id] = te
        })
                        
        XCTAssertEqual(entityState.values.count, 3, "There should be only 3 TE")
        
        let action = EntityAction<MockEntity>.clear
        _ = reducer.run(&entityState, action, api)
        
        XCTAssertEqual(entityState.values.count, 0, "There should not be any TE")
    }
}
