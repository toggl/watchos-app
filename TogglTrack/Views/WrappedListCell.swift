//
//  WrappedListCell.swift
//  TogglWatch WatchKit Extension
//
//  Created by Ricardo Sánchez Sotres on 27/11/2019.
//  Copyright © 2019 Toggl. All rights reserved.
//

import SwiftUI

struct WrappedListSizeKey: PreferenceKey
{
    typealias Value = [CGSize]
    static var defaultValue: [CGSize] { [] }
    
    static func reduce(value: inout [CGSize], nextValue: () -> [CGSize])
    {
        value.append(contentsOf: nextValue())
    }
}

struct WrappedListSizeKeySetter: View
{
    var body: some View
    {
        GeometryReader { geometry in
            Color.clear
                .preference(key: WrappedListSizeKey.self,
                            value: [geometry.size])
        }
    }
}

struct WrappedListCell<CellView: View>: View
{
    let content: CellView
    
    var body: some View
    {
        self.content
            .background(WrappedListSizeKeySetter())
    }
}
