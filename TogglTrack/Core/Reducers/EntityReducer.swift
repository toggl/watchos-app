//
//  EntityReducer.swift
//  TogglWatch
//
//  Created by Ricardo Sánchez Sotres on 20/11/2019.
//  Copyright © 2019 Toggl. All rights reserved.
//

import Foundation

public func createEntityReducer<Entity: Identifiable>() -> Reducer<[Entity.ID: Entity], EntityAction<Entity>, APIProtocol, AppAction>
{
    return Reducer { state, action, api in
        
        switch action {
            
        case let .setEntities(entities):
            state = entities.reduce([:], { acc, e in
                var acc = acc
                acc[e.id] = e
                return acc
            })
            
            return .empty
            
        case .clear:
            state = [:]
            return .empty
        }
    }
}
