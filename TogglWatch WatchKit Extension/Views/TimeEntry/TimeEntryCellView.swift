//
//  TimeEntryView.swift
//  TogglWatch WatchKit Extension
//
//  Created by Ricardo Sánchez Sotres on 15/10/2019.
//  Copyright © 2019 Toggl. All rights reserved.
//

import SwiftUI
import TogglTrack

public enum SwipeButtonType
{
    case continueTimeEntry
    case deleteTimeEntry
}

public struct SwipeButton: View
{
    var type: SwipeButtonType
    var p: CGFloat
    var action: () -> Void
    
    public var body: some View
    {
        ZStack {
            if self.type == .continueTimeEntry {
                Color.green.cornerRadius(9)
            } else {
                Color.red.cornerRadius(9)
            }
            Image(systemName: self.type == .continueTimeEntry ? "play.fill" : "trash.fill")
        }
        .opacity(Double(self.p * 0.5 + 0.5))
        .scaleEffect(min(self.p * 0.3 + 0.7, 1.0))
        .animation(Animation.default)
        .onTapGesture {
            self.action()
        }
    }
}

public struct TimeEntryCellView: View
{
    @State var percentDragged: CGFloat = 0
    @State var dragging = false
    @State var maxDrag: CGFloat = 1
    @State var startingValue: CGFloat = 0
    
    @Binding var visibleActionId: Int
    
    let timeEntry: TimeEntryModel
    let onContinueTimeEntry: (TimeEntryModel) -> ()
    let onDeleteTimeEntry: (TimeEntryModel) -> ()
    
    var isSwiped: Bool {
        return visibleActionId == timeEntry.id
    }
    
    public init(
        _ timeEntry: TimeEntryModel,
        onContinueTimeEntry: @escaping (TimeEntryModel) -> (),
        onDeleteTimeEntry: @escaping (TimeEntryModel) -> (),
        visibleActionId: Binding<Int>)
    {
        self.timeEntry = timeEntry
        self.onContinueTimeEntry = onContinueTimeEntry
        self.onDeleteTimeEntry = onDeleteTimeEntry
        self._visibleActionId = visibleActionId
    }
    
    public var body: some View
    {
        ZStack {
            HStack(spacing: 10) {
                SwipeButton(type: .continueTimeEntry, p: isSwiped ? abs(percentDragged) : 0, action: {
                    self.onContinueTimeEntry(self.timeEntry)
                    self.percentDragged = 0
                })
                SwipeButton(type: .deleteTimeEntry, p: isSwiped ? abs(percentDragged) : 0, action: {
                    self.onDeleteTimeEntry(self.timeEntry)
                    self.percentDragged = 0
                })
            }
            .opacity((abs(self.percentDragged) > 0) ? 1.0 : 0.0)
            
            VStack(alignment: .leading) {
                Text(timeEntry.descriptionString)
                    .font(.system(size: 16))
                    .multilineTextAlignment(.leading)
                    .lineLimit(3)
                    .foregroundColor(timeEntry.descriptionColor)
                
                ProjectTaskClientTextView(timeEntry)
                    .multilineTextAlignment(.leading)
                    .lineLimit(3)
                
                HStack {
                    Spacer()
                    Text(timeEntry.durationString ?? "")
                        .font(.system(size: 14))
                        .foregroundColor(Color.togglGray)
                        .multilineTextAlignment(.trailing)
                }
            }
            .padding(EdgeInsets(top: 4, leading: 7, bottom: 2, trailing: 7))
            .background(
                GeometryReader { geometry in
                    Color.togglDarkGray
                        .cornerRadius(9)
                        .onAppear{
                            self.maxDrag = geometry.size.width / 2
                    }
                }
            )
            .offset(CGSize(width: isSwiped ? percentDragged * maxDrag : 0, height: 0))
            .animation(dragging ? nil : Animation.default)
            .gesture(
                DragGesture(minimumDistance: 20)
                    .onChanged{ value in
                        if !self.isSwiped {
                            self.percentDragged = 0
                            self.startingValue = 0
                        }
                        
                        self.visibleActionId = self.timeEntry.id

                        self.dragging = true
                        if value.translation.height > value.translation.width {
                            self.percentDragged = 0
                        }
                        
                        self.percentDragged = (-1.0...1.0).clamp(self.startingValue + value.translation.width / self.maxDrag)
                    }
                    .onEnded{ value in
                        self.dragging = false
                        switch self.percentDragged {
                        case 0.5...1:
                            self.percentDragged = 1
                        case -1.0...(-0.5):
                            self.percentDragged = -1
                        default:
                            self.percentDragged = 0
                        }
                        
                        self.startingValue = self.percentDragged
                    }
            )
        }
    }
}
