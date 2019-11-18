//
//  EndPoint.swift
//  TogglWatch WatchKit Extension
//
//  Created by Ricardo Sánchez Sotres on 28/10/2019.
//  Copyright © 2019 Toggl. All rights reserved.
//

import Foundation

public struct Endpoint<A>
{
    public enum Method: String
    {
        case get = "GET"
        case post = "POST"
        case put = "PUT"
        case patch = "PATCH"
        case delete = "DELETE"
    }
    
    public typealias ParserClosure = (Data?) throws -> A
    
    public var request: URLRequest
    var parse: ParserClosure
    var expectedStatusCode: (Int) -> Bool = { code in code >= 200 && code < 300 }
    
    public init(_ method: Method,
                url: URL,
                body: Data? = nil,
                headers: [String:String] = [:],
                timeOutInterval: TimeInterval = 10,
                query: [String:String] = [:],
                parse: @escaping ParserClosure
    )
    {
        var requestUrl : URL
        if query.isEmpty {
            requestUrl = url
        } else {
            var comps = URLComponents(url: url, resolvingAgainstBaseURL: true)!
            comps.queryItems = comps.queryItems ?? []
            comps.queryItems!.append(contentsOf: query.map { URLQueryItem(name: $0.0, value: $0.1) })
            requestUrl = comps.url!
        }
        
        request = URLRequest(url: requestUrl)
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        for (key, value) in headers {
            request.setValue(value, forHTTPHeaderField: key)
        }
        request.timeoutInterval = timeOutInterval
        request.httpMethod = method.rawValue
        
        // body *needs* to be the last property that we set, because of this bug: https://bugs.swift.org/browse/SR-6687
        request.httpBody = body
        
        self.parse = parse
    }
}

extension Endpoint where A: Decodable
{
    public init(json method: Method, url: URL, headers: [String: String] = [:], query: [String: String] = [:], decoder: JSONDecoder = JSONDecoder())
    {
        self.init(method, url: url, body: nil, headers: headers, query: query) { data in
            guard let dat = data else { throw NetworkingError.unknown }
            return try decoder.decode(A.self, from: dat)
        }
    }
    
    public init<B: Encodable>(json method: Method, url: URL, body: B? = nil, headers: [String: String] = [:], query: [String: String] = [:], decoder: JSONDecoder = JSONDecoder())
    {
        let b = body.map { try! JSONEncoder().encode($0) }
        self.init(method, url: url, body: b, headers: headers, query: query) { data in
            guard let dat = data else { throw NetworkingError.unknown }
            return try decoder.decode(A.self, from: dat)
        }
    }
 }

extension Endpoint where A == ()
{
    public init(_ method: Method, url: URL, headers: [String:String] = [:], query: [String:String] = [:])
    {
        self.init(method, url: url, headers: headers, query: query, parse: { _ in return })
    }
    
    public init<B: Encodable>(json method: Method, url: URL, body: B, headers: [String:String] = [:], query: [String:String] = [:])
    {
        let b = try! JSONEncoder().encode(body)
        self.init(method, url: url, body: b, headers: headers, query: query, parse: { _ in return })
    }
}
