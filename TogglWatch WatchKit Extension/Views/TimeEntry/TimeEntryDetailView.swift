//
//  TimeEntryDetailView.swift
//  TogglWatch WatchKit Extension
//
//  Created by Ricardo Sánchez Sotres on 25/11/2019.
//  Copyright © 2019 Toggl. All rights reserved.
//

import SwiftUI
import TogglTrack
import Combine

private let sidePadding: CGFloat = 11

struct DetailSection<TitleView: View, ContentView: View>: View
{
    let title: TitleView
    let content: () -> ContentView
    
    var body: some View
    {
        VStack(alignment: .leading, spacing: 4) {
            Divider().padding(.bottom, 4)
            title
                .font(.system(size: 11))
                .foregroundColor(Color.togglGray)
                .padding(.horizontal, sidePadding)
            content()
                .font(.system(size: 14))
                .foregroundColor(Color.togglGray)
                .padding(.horizontal, sidePadding)
        }
    }
}

struct TimeFrameView: View
{
    var timeEntry: TimeEntryModel

    var body: some View
    {
        VStack {
            HStack {
                Text("START")
                    .font(.system(size: 11))
                Spacer()
                Text(self.timeEntry.start.toTimeString())
            }
            
            HStack {
                Text("END")
                    .font(.system(size: 11))
                Spacer()
                if self.timeEntry.end == nil {
                    Text("...")
                } else {
                    Text(self.timeEntry.end!.toTimeString())
                }
            }
        }
    }
}

struct DurationView: View
{
    var timeEntry: TimeEntryModel
    var now: Date

    var body: some View
    {
        Group {
            if self.timeEntry.durationString != nil {
                Text(self.timeEntry.durationString!)
            } else {
                Text("\(self.now.timeIntervalSince(self.timeEntry.start).toIntervalString())")
            }
        }
    }
}

struct TimeEntryDetailView: View
{
    var timeEntry: TimeEntryModel
    
    @ObservedObject var store: Store<TimelineState, TimelineAction, AppEnvironment>
    @State var timer: ObservableTimer = ObservableTimer()
    @State var now: Date = Date()
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>

    var body: some View
    {
        ScrollView {
            VStack(alignment: .leading) {
                
                HStack(alignment: .center, spacing: 4) {
                    
                    if timeEntry.isRunning {
                        Button(action: {}) {
                            Text("Stop")
                        }
                        .background(Color.togglRed)
                        .cornerRadius(20)
                    } else {
                        Button(action: {}) {
                            Text("Continue")
                        }
                        .background(Color.togglGreen)
                        .cornerRadius(20)
                    }
                    
                    Button(action: {
                        self.store.send(.deleteEntry(self.timeEntry.id))
                        self.presentationMode.wrappedValue.dismiss()
                    }) {
                        Image(systemName: "trash")
                    }
                    .background(Color.togglDarkRed)
                    .cornerRadius(20)
                    .frame(width:47)
                }
                .padding(.vertical, 9)

                DetailSection(title: EmptyView()) {
                    VStack(alignment: .leading) {
                        Text(self.timeEntry.descriptionString)
                            .font(.system(size: 16))
                            .foregroundColor(self.timeEntry.descriptionColor)
                            .multilineTextAlignment(.leading)
                            .lineLimit(5)
                        
                        ProjectTextView(self.timeEntry)
                            .multilineTextAlignment(.leading)
                            .lineLimit(3)
                    }
                }
                
                if timeEntry.client != nil {
                    DetailSection(title: Text("CLIENT")) {
                        Text(self.timeEntry.client!.name)
                    }
                }
                
                if (timeEntry.task != nil) {
                    DetailSection(title: Text("TASK")) {
                        Text(self.timeEntry.task!.name)
                    }
                }
                
                if timeEntry.tags != nil {
                    DetailSection(title: EmptyView()) {
                        TagsView(self.timeEntry.tags!)
                    }
                }
                
                DetailSection(title: HStack {
                    Image(systemName: "clock")
                    Text("TIME")
                }) {
                    TimeFrameView(timeEntry: self.timeEntry)
                }
                
                DetailSection(title: HStack {
                    Image(systemName: "stopwatch")
                    Text("DURATION")
                }) {
                    DurationView(timeEntry: self.timeEntry, now: self.now)
                        .onAppear {
                            self.now = Date()
                            self.timer = ObservableTimer()
                        }
                        .onReceive(self.timer.currentTimePublisher) { newCurrentTime in
                            self.now = newCurrentTime
                        }
                }
                
                DetailSection(title: HStack {
                    Image(systemName: "calendar")
                    Text("DATE")
                }) {
                    Text(self.timeEntry.start.toDayString())
                }
            }
            .padding(.horizontal, 4)
        }
    .navigationBarTitle("Back")
    }
}
