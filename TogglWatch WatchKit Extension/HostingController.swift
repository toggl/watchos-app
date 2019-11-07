//
//  HostingController.swift
//  TogglWatch WatchKit Extension
//
//  Created by Ricardo Sánchez Sotres on 15/10/2019.
//  Copyright © 2019 Toggl. All rights reserved.
//

import WatchKit
import Foundation
import SwiftUI
import Architecture
import Core

class HostingController: WKHostingController<ContentView> {
    override var body: ContentView {
         return ContentView(store: Store(
            initialState: AppState(),
            reducer: logging(appReducer),
            environment: AppEnvironment()
            )
        )
    }
}
