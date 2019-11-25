//
//  ArrayExtensions.swift
//  TogglWatch WatchKit Extension
//
//  Created by Ricardo Sánchez Sotres on 22/11/2019.
//  Copyright © 2019 Toggl. All rights reserved.
//

import Foundation

extension Array
{
    public func grouped<Key: Hashable>(by selectKey: (Element) -> Key) -> [[Element]]
    {
        var groups = [Key:[Element]]()
        
        for element in self
        {
            let key = selectKey(element)
            
            if case nil = groups[key]?.append(element)
            {
                groups[key] = [element]
            }
        }
        
        return groups.map { $0.value }
    }
}
