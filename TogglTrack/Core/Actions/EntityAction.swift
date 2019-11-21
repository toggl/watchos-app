//
//  EntityAction.swift
//  TogglWatch WatchKit Extension
//
//  Created by Ricardo Sánchez Sotres on 06/11/2019.
//  Copyright © 2019 Toggl. All rights reserved.
//

import Foundation

public enum EntityAction<Entity>
{
    case setEntities([Entity])
    case clear
}

extension EntityAction: CustomStringConvertible
{
    public var description: String
    {
        switch self {
        case .setEntities(_):
            return "Set"
        case .clear:
            return "Clear"
        }
    }
}
