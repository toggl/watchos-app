//
//  EmptyTimelineView.swift
//  TogglWatch WatchKit Extension
//
//  Created by Ricardo Sánchez Sotres on 10/12/2019.
//  Copyright © 2019 Toggl. All rights reserved.
//

import SwiftUI

struct EmptyTimelineView: View
{
    public var refreshAction: () -> ()
    @State var p: CGFloat = 0
    
    let initialY: CGFloat = -150
    let finalY: CGFloat = 20
    
    init(refreshAction: @escaping () -> ())
    {
        self.refreshAction = refreshAction
        self.p = 0
    }
    
    var body: some View
    {
        GeometryReader { geometry in
            ZStack {
                Image("spider")
                    .offset(y: (self.p * (self.finalY - self.initialY) + self.initialY) - geometry.size.height/2)
                    .animation(Animation.spring(response: 0.55, dampingFraction: 0.3, blendDuration: 2.0))
                
                VStack {
                    Text("No time entries")
                    Text("(tap to refresh)")
                        .font(.footnote)
                }
                .offset(y: geometry.size.height/2)
                    .opacity(Double(self.p))
                    .animation(Animation.default)
            }
            .onAppear {
                self.p = 1
            }
            .onTapGesture(perform: self.refreshAction)
        }
    }
    
}
