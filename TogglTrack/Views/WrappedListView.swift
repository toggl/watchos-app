//
//  GridView.swift
//  TogglWatch WatchKit Extension
//
//  Created by Ricardo Sánchez Sotres on 27/11/2019.
//  Copyright © 2019 Toggl. All rights reserved.
//

import SwiftUI

public struct WrappedListView<Element, Cell>: View where Element: Identifiable, Cell: View
{
    let elements: [Element]
    let spacing: CGFloat
    let content: (Element) -> Cell
    @State var positions: [CGPoint] = []
    @State var totalHeight: CGFloat = 0
    
    public init(elements: [Element], spacing: CGFloat, content: @escaping (Element) -> Cell)
    {
        self.elements = elements
        self.spacing = spacing
        self.content = content
    }
    
    public init(elements: [Element], content: @escaping (Element) -> Cell)
    {
        self.init(elements: elements, spacing: 0, content: content)
    }
    
    public var body: some View
    {
        GeometryReader { geometry in
            ZStack {
                ForEach(0..<self.elements.count) { n in
                    WrappedListCell(content: self.content(self.elements[n]))
                        .position(self.positions.safeGet(n) ?? CGPoint.zero)
                }
            }
            .onPreferenceChange(WrappedListSizeKey.self) { preferences in
                guard !preferences.isEmpty else {
                    self.positions = []
                    return
                }
                var auxPositions:[CGPoint] = []
                var auxTotalHeight: CGFloat = 0
                var accWidth: CGFloat = 0
                var line = 0
                for i in 0..<self.elements.count {
                    let elementWidth = preferences[i].width + self.spacing
                    let elementHeight = preferences[i].height + self.spacing
                    if accWidth + elementWidth > geometry.size.width {
                        if (accWidth > 0) {
                            line += 1
                        }
                        accWidth = 0
                    }
                    auxPositions.append(
                        CGPoint(x: accWidth + elementWidth / 2, y: CGFloat(line) * elementHeight + elementHeight / 2)
                    )
                    accWidth += elementWidth
                    auxTotalHeight = CGFloat(line) * elementHeight + elementHeight
                }
                
                self.totalHeight = auxTotalHeight
                self.positions = auxPositions
            }
        }
        .frame(height: totalHeight)
    }
}
