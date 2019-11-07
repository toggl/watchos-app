//
//  TimeEntryView.swift
//  TogglWatch WatchKit Extension
//
//  Created by Ricardo Sánchez Sotres on 15/10/2019.
//  Copyright © 2019 Toggl. All rights reserved.
//

import SwiftUI
import Model

public struct TimeEntryCellView: View
{
    let viewModel: TimeEntryModel

    public init(viewModel: TimeEntryModel)
    {
        self.viewModel = viewModel
    }
    
    public var body: some View
    {
        VStack {
            Text(viewModel.description)
            Text(viewModel.durationString)
                .font(.footnote)
        }
    }
}

/*
struct TimeEntryView_Previews: PreviewProvider {
    static var previews: some View {
        TimeEntryCellView(viewModel:
            TimeEntryModel(
                id: 0,
                description: "This is a test",
                start: Date(),
                billable: true,
                workspace: Workspace.dummyWorkspace,
                duration: 0,
                project: nil,
                tags: nil
            )
        )
    }
}
*/
