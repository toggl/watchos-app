//
//  WorkspaceAction.swift
//  TogglWatch WatchKit Extension
//
//  Created by Ricardo Sánchez Sotres on 06/11/2019.
//  Copyright © 2019 Toggl. All rights reserved.
//

import Foundation
import Model

public enum WorkspaceAction
{
    case setWorkspaces([Workspace])
    case loadWorkspaces
}
