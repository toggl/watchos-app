//
//  TimeEntryView.swift
//  TogglWatch WatchKit Extension
//
//  Created by Ricardo Sánchez Sotres on 15/10/2019.
//  Copyright © 2019 Toggl. All rights reserved.
//

import SwiftUI
import TogglTrack

public struct TimeEntryCellView: View
{
    let viewModel: TimeEntryModel
    
    public init(viewModel: TimeEntryModel)
    {
        self.viewModel = viewModel
    }
    
    public var body: some View
    {
        VStack(alignment: .leading) {
            Text(viewModel.descriptionString)
                .font(.system(size: 16))
                .multilineTextAlignment(.leading)
                .lineLimit(3)
                .foregroundColor(viewModel.descriptionColor)
            
            if viewModel.projectTaskClientString != "" {
                (
                    Text("• ")
                        .foregroundColor(viewModel.projectColor)
                        .font(.system(size: 20))
                    + Text(viewModel.projectTaskClientString)
                        .font(.system(size: 14))
                )
                    .multilineTextAlignment(.leading)
                    .lineLimit(3)
            }
            
            HStack {
                Spacer()
                Text(viewModel.durationString)
                    .font(.system(size: 14))
                    .foregroundColor(Color.init(red: 174/255, green: 180/255, blue: 191/255))
                    .multilineTextAlignment(.trailing)
            }
        }
        .listRowPlatterColor(Color.init(red: 242/255, green: 244/255, blue: 252/255, opacity: 0.07))
        .cornerRadius(9)
    }
}


struct TimeEntryView_Previews: PreviewProvider {
    static var previews: some View {
        List {
            TimeEntryCellView(viewModel:
                TimeEntryModel(
                    timeEntry: TimeEntry.dummyEntries[0],
                    workspace: Workspace.dummyWorkspace,
                    project: Project.dummyProjects[0],
                    client: Client.dummyClients[0],
                    task: Task.dummyTask[0]
                )
            )
            TimeEntryCellView(viewModel:
                TimeEntryModel(
                    timeEntry: TimeEntry.dummyEntries[1],
                    workspace: Workspace.dummyWorkspace
                )
            )
            TimeEntryCellView(viewModel:
                TimeEntryModel(
                    timeEntry: TimeEntry.dummyEntries[2],
                    workspace: Workspace.dummyWorkspace
                )
            )
        }
    }
}
