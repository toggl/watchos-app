//
//  RunningTimeEntryView.swift
//  TogglWatch WatchKit Extension
//
//  Created by Juxhin Bakalli on 3/12/19.
//  Copyright © 2019 Toggl. All rights reserved.
//

import SwiftUI
import TogglTrack

struct RunningTimeEntryView: View
{
    var timeEntry: TimeEntryModel
    var stopAction: () -> Void
    @State var timer: ObservableTimer = ObservableTimer()
    @State var now: Date = Date()
    
    public init(_ timeEntry: TimeEntryModel, onStopAction: @escaping () -> Void)
    {
        self.timeEntry = timeEntry
        self.stopAction = onStopAction
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(timeEntry.descriptionString)
                .font(.system(size: 16))
                .multilineTextAlignment(.leading)
                .lineLimit(3)
                .foregroundColor(timeEntry.descriptionColor)
            
            ProjectTaskClientTextView(timeEntry)
                .lineLimit(3)
            
            HStack(alignment: .center, spacing: 1) {
                
                Text("\(self.now.timeIntervalSince(self.timeEntry.start).toIntervalString())")
                .frame(alignment: .leading)
                .onAppear {
                    self.now = Date()
                    self.timer = ObservableTimer()
                }
                .onReceive(self.timer.currentTimePublisher) { newCurrentTime in
                    self.now = newCurrentTime
                }
                .font(.system(size: 20))
                .multilineTextAlignment(.leading)
                
                Spacer()
                
                Color.togglRed.cornerRadius(17)
                    .overlay(Image("stopWhite"))
                    .frame(width: 34, height: 34)
                    .onTapGesture { self.stopAction() }
            }
        }
        .padding(.top, 4)
        .padding(.bottom, -14)
    }
}
