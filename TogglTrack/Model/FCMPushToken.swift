//
//  FCMPushToken.swift
//  TogglWatch
//
//  Created by Juxhin Bakalli on 16/12/19.
//  Copyright © 2019 Toggl. All rights reserved.
//

import Foundation

public struct FCMPushToken: Codable, Equatable
{
    public let fcmToken: String?
    public let status: String?
    public let apnToken: String
    
    private let bundleId = (Bundle.main.infoDictionary?["CFBundleIdentifier"] as? String)?.replacingOccurrences(of: ".extension", with: "") ?? ""
    
#if DEBUG
    private let sandbox = true
#else
    private let sandbox = false
#endif
    
    public init(_ apnToken: String, fcmToken: String? = nil)
    {
        self.apnToken = apnToken
        self.fcmToken = fcmToken
        self.status = nil
    }
    
    enum CodingKeys: String, CodingKey
    {
        case apnToken = "apns_token"
        case fcmToken = "registration_token"
        case status
    }
    
    enum EncodeKeys: String, CodingKey
    {
        case apnToken = "apns_tokens"
        case application
        case sandbox
    }
    
    public func encode(to encoder: Encoder) throws
    {
        var container = encoder.container(keyedBy: EncodeKeys.self)
        
        try container.encode([apnToken], forKey: .apnToken)
        try container.encode(bundleId.appending(".complication"), forKey: .application)
        try container.encode(sandbox, forKey: .sandbox)
    }
    
    public func toTogglPushToken() -> TogglPushToken?
    {
        guard let fcmToken = fcmToken else { return nil }
        return TogglPushToken(fcmToken)
    }
}

public struct FCMResponse: Codable, Equatable
{
    let fcmTokens: [FCMPushToken]?
    
    private enum CodingKeys: String, CodingKey
    {
        case fcmTokens = "results"
    }
}

public struct TogglPushToken: Encodable, Equatable
{
    public let token: String
    
    public init(_ token: String)
    {
        self.token = token
    }
    
    enum CodingKeys: String, CodingKey
    {
        case token = "fcm_registration_token"
    }
}
