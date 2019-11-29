//
//  ProjectTaskClientTextView.swift
//  TogglWatch WatchKit Extension
//
//  Created by Ricardo Sánchez Sotres on 26/11/2019.
//  Copyright © 2019 Toggl. All rights reserved.
//

import SwiftUI
import TogglTrack

struct ProjectTaskClientTextView: View
{
    var timeEntry: TimeEntryModel
    
    public init(_ timeEntry: TimeEntryModel)
    {
        self.timeEntry = timeEntry
    }
    
    var body: some View {
        Group {
            if timeEntry.projectTaskClientString != "" {
                Text("• ")
                    .font(.system(size: 20))
                    .foregroundColor(timeEntry.projectColor)
                    + Text(timeEntry.projectTaskClientString)
                        .font(.system(size: 14))
            } else {
                EmptyView()
            }
        }
    }
}
