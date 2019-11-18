//
//  ErrorExtensions.swift
//  TogglWatch WatchKit Extension
//
//  Created by Ricardo Sánchez Sotres on 18/11/2019.
//  Copyright © 2019 Toggl. All rights reserved.
//

import Foundation

public extension Error
{
    var description: String
    {
        switch self {
        
        case let error as NetworkingError:
            switch error
            {
            case .noData:
                return "No data returned from the server"
            case let .wrongStatus(code, _):
                switch code {
                case 403:
                    return "Incorrect email or password"
                default:
                    return "Wrong server status: \(code)"
                }                
            case .unknown:
                return "Something is wrong with the server"
            }
        
        case let error as NSError:
            return error.localizedDescription
            
        default:
            break
        }
        
        return "Oops! Something has gone wrong..."
    }
}
