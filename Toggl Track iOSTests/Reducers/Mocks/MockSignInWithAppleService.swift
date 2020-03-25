//
//  MockSignInWithAppleService.swift
//  Toggl Track iOSTests
//
//  Created by Juan Laube on 3/3/20.
//  Copyright © 2020 Toggl. All rights reserved.
//

import Foundation
import Combine
@testable import TogglTrack

class MockSignInWithAppleService: SignInWithAppleServiceProtocol {
    func getToken() -> AnyPublisher<String, Error> {
        return Just("token")
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()
    }
}
