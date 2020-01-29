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

class HostingController: WKHostingController<ContentView>
{
    var store: Store<AppState, AppAction, AppEnvironment> = {
        let urlSession = URLSession(configuration: URLSessionConfiguration.default)
        
        let environment = AppEnvironment(
            api: API(urlSession: urlSession),
            firebaseAPI: FirebaseAPI(urlSession: urlSession),
            keychain: Keychain(),
            dateService: DateService(),
            pushTokenStorage: PushTokenStorage()
        )
        
        return  Store(
            initialState: AppState(),
            reducer: logging(combinedReducer),
            environment: environment
        )
    }()
    
    override var body: ContentView
    {
        return ContentView(store: store)
    }
    
    public func didBecomeActive()
    {
        guard let _ = store.state.user else { return }
        store.send(.loadAll(force: false))
    }
}
