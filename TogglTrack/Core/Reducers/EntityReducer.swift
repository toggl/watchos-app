//
//  EntityReducer.swift
//  TogglWatch
//
//  Created by Ricardo Sánchez Sotres on 20/11/2019.
//  Copyright © 2019 Toggl. All rights reserved.
//

import Foundation

public func createEntityReducer<Entity: Identifiable>() -> Reducer<[Entity.ID: Entity], EntityAction<Entity>, APIProtocol>
{
    return Reducer { state, action, api in
        
        switch action {
        
        case let .setEntities(entities):
            state = [:]
            for entity in entities
            {
                state[entity.id] = entity
            }
            return .empty
        
        case .clear:
            state = [:]
            return .empty
        }
        
    }
}
