//
//  MockFirebaseAPI.swift
//  Toggl Track iOSTests
//
//  Created by Juxhin Bakalli on 16/12/19.
//  Copyright © 2019 Toggl. All rights reserved.
//

import Foundation
import Combine
@testable import TogglTrack

class MockFirebaseAPI: FirebaseAPIProtocol
{
    var returnedFcmToken: FCMPushToken?
    var returnedError: Error = MockError.unknown
    
    func getFCMToken(for token: FCMPushToken) -> AnyPublisher<FCMResponse, Error>
    {
        guard let token = returnedFcmToken else {
            return Fail(error: returnedError)
                .eraseToAnyPublisher()
        }
        
        return Just(FCMResponse(fcmTokens: [token]))
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()
    }
}
