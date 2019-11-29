//
//  ProjectTextView.swift
//  TogglWatch WatchKit Extension
//
//  Created by Ricardo Sánchez Sotres on 28/11/2019.
//  Copyright © 2019 Toggl. All rights reserved.
//

import SwiftUI
import TogglTrack

struct ProjectTextView: View
{
    var timeEntry: TimeEntryModel
    
    public init(_ timeEntry: TimeEntryModel)
    {
        self.timeEntry = timeEntry
    }
    
    var body: some View {
        Group {
            if timeEntry.project?.name != nil {
                HStack(alignment: .firstTextBaseline, spacing: 4) {
                    Text("•")
                        .font(.system(size: 20))
                        .foregroundColor(timeEntry.projectColor)
                    Text(timeEntry.project!.name)
                        .font(.system(size: 14))
                        .foregroundColor(Color.togglGray)
                }
            } else {
                EmptyView()
            }
        }
    }
}
