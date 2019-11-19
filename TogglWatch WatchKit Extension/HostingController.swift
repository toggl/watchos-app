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
import TogglTrack

class HostingController: WKHostingController<ContentView> {
    override var body: ContentView {
        
        let environment = AppEnvironment(
            api: API(urlSession: URLSession(configuration: URLSessionConfiguration.default)),
            keychain: Keychain()
        )
        
        return ContentView(store: Store(
            initialState: AppState(),
            reducer: logging(appReducer),
            environment: environment
            )
        )
    }
}
