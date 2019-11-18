//
//  UserAction.swift
//  TogglWatch
//
//  Created by Juxhin Bakalli on 15/11/19.
//  Copyright © 2019 Toggl. All rights reserved.
//

import Foundation

public enum UserAction
{
    case login(String, String)
    case setUser(User)
    case setError(Error?)
    case loadAPITokenAndUser
    case logout
}
