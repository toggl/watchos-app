//
//  PushTokenStorage.swift
//  TogglWatch
//
//  Created by Juxhin Bakalli on 16/12/19.
//  Copyright © 2019 Toggl. All rights reserved.
//

import Foundation

public protocol PushTokenStorageProtocol
{
    func save(token: FCMPushToken)
    func loadAPNToken() -> FCMPushToken?
}

public class PushTokenStorage: PushTokenStorageProtocol
{
    private let userDefaultsAPNTokenKey = "userDefaultsAPNTokenKey"
    private let userDefaultsFCMTokenKey = "userDefaultsFCMTokenKey"

    public func save(token: FCMPushToken)
    {
        UserDefaults.standard.set(token.apnToken, forKey: userDefaultsAPNTokenKey)
        UserDefaults.standard.set(token.fcmToken, forKey: userDefaultsFCMTokenKey)
    }
    
    public func loadAPNToken() -> FCMPushToken?
    {
        guard
            let apnToken = UserDefaults.standard.string(forKey: userDefaultsAPNTokenKey),
            let fcmToken = UserDefaults.standard.string(forKey: userDefaultsFCMTokenKey)
        else { return nil }
        return FCMPushToken(apnToken, fcmToken: fcmToken)
    }
    
    public init() {}
}
