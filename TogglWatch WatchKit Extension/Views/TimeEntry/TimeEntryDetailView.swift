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
    @EnvironmentObject var store: Store<AppState, AppAction, AppEnvironment>
    var timeEntryId: Int
    
    @State var timer: ObservableTimer = ObservableTimer()
    @State var now: Date = Date()
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    @State var showDeleteAlert: Bool = false
    
    var body: some View
    {
        Group {
            if store.state.timeline.timeEntryFor(id: timeEntryId) == nil {
                EmptyView()
            } else {
                timeEntryView(store.state.timeline.timeEntryFor(id: timeEntryId)!)
            }
        }
    }
    
    func timeEntryView(_ timeEntry: TimeEntryModel) -> some View
    {
        ScrollView {
            VStack(alignment: .leading) {
                
                HStack(alignment: .center, spacing: 4) {
                    
                    if timeEntry.isRunning {
                        Button(action: { self.store.send(.timeline(.stopRunningEntry)) }) {
                            Text("Stop")
                        }
                        .background(Color.togglRed)
                        .cornerRadius(20)
                    } else {
                        Button(action: {
                            self.store.send(.timeline(.continueEntry(timeEntry.id)))
                            self.presentationMode.wrappedValue.dismiss()
                        }) {
                            Text("Continue")
                        }
                        .background(Color.togglGreen)
                        .cornerRadius(20)
                    }
                    
                    Button(action: {
                        self.showDeleteAlert = true
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
                        Text(timeEntry.descriptionString)
                            .font(.system(size: 16))
                            .foregroundColor(timeEntry.descriptionColor)
                            .multilineTextAlignment(.leading)
                            .lineLimit(5)
                        
                        ProjectTextView(timeEntry)
                            .multilineTextAlignment(.leading)
                            .lineLimit(3)
                    }
                }
                
                if timeEntry.client != nil {
                    DetailSection(title: Text("CLIENT")) {
                        Text(timeEntry.client!.name)
                    }
                }
                
                if (timeEntry.task != nil) {
                    DetailSection(title: Text("TASK")) {
                        Text(timeEntry.task!.name)
                    }
                }
                
                if timeEntry.tags != nil && timeEntry.tags?.count != 0 {
                    DetailSection(title: EmptyView()) {
                        TagsView(timeEntry.tags!)
                    }
                }
                
                DetailSection(title: HStack {
                    Image(systemName: "clock")
                    Text("TIME")
                }) {
                    TimeFrameView(timeEntry: timeEntry)
                }
                
                DetailSection(title: HStack {
                    Image(systemName: "stopwatch")
                    Text("DURATION")
                }) {
                    DurationView(timeEntry: timeEntry, now: self.now)
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
                    Text(timeEntry.start.toDayString())
                }
            }
            .padding(.horizontal, 4)
        }
        .navigationBarTitle("Back")
        .sheet(isPresented: $showDeleteAlert, content: {
            VStack {
                Spacer()
                Text("Are you sure you want to delete this Time Entry?")
                Spacer()
                Button(
                    action: {
                        self.showDeleteAlert = false
                        self.store.send(.timeline(.deleteEntry(timeEntry.id)))
                        self.presentationMode.wrappedValue.dismiss()
                },
                    label: {
                        Text("Delete").foregroundColor(Color.togglRed)
                })
            }
        })
    }
}

