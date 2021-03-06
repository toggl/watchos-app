//
//  FirebaseAPI.swift
//  TogglWatch
//
//  Created by Juxhin Bakalli on 16/12/19.
//  Copyright © 2019 Toggl. All rights reserved.
//

import Foundation
import Combine

public protocol FirebaseAPIProtocol
{
    func getFCMToken(for token: FCMPushToken) -> AnyPublisher<FCMResponse, Error>
}

public class FirebaseAPI : FirebaseAPIProtocol
{
    private let baseURL: String = "https://iid.googleapis.com/iid/v1"
    private var headers: [String : String]
    
    private let urlSession: URLSessionProtocol
    private var jsonDecoder: JSONDecoder
    
    public init(urlSession: URLSessionProtocol)
    {
        self.urlSession = urlSession
        
        jsonDecoder = JSONDecoder()
        jsonDecoder.dateDecodingStrategy = .iso8601
        
        var firebaseServerKey: String = ""
        
        if let path = Bundle.main.path(forResource: "Secrets", ofType: "plist"), let secrets = NSDictionary(contentsOfFile: path) as? [String: String] {
            firebaseServerKey = secrets["FIREBASE_SERVER_KEY"] ?? ""
        }
        
        headers = [
            "Content-Type": "application/json",
            "Authorization": firebaseServerKey
        ]
    }
    
    public func getFCMToken(for token: FCMPushToken) -> AnyPublisher<FCMResponse, Error>
    {
        let endpoint =  Endpoint<FCMResponse>(
            json: .post,
            url: URL(string: baseURL + ":batchImport")!,
            body: token,
            headers: headers,
            decoder: jsonDecoder
        )
        return urlSession.load(endpoint)
    }
}
