//
//  MockPushNotificationStorage.swift
//  Toggl Track iOSTests
//
//  Created by Juxhin Bakalli on 16/12/19.
//  Copyright © 2019 Toggl. All rights reserved.
//

import Foundation
@testable import TogglTrack

class MockPushTokenStorage: PushTokenStorageProtocol
{
    var returnedFcmToken: FCMPushToken?
        
    func save(token: FCMPushToken) {
        returnedFcmToken = token
    }
    
    func loadAPNToken() -> FCMPushToken? {
        return returnedFcmToken
    }
}
