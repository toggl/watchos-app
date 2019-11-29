//
//  TagsView.swift
//  TogglWatch WatchKit Extension
//
//  Created by Ricardo Sánchez Sotres on 27/11/2019.
//  Copyright © 2019 Toggl. All rights reserved.
//

import SwiftUI
import TogglTrack

struct TagsView: View
{
    var tags: [Tag]
    
    public init (_ tags: [Tag])
    {
        self.tags = tags
    }
    
    var body: some View
    {
        WrappedListView(elements: tags, spacing: 5) { tag in
            Text(tag.name)
                .font(.system(size: 14))
                .foregroundColor(Color.togglGray)
                .padding(2)
                .padding(.horizontal, 6)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.white.opacity(0.2), lineWidth: 1)
                )
                .frame(height: 18)
        }
    }
}
