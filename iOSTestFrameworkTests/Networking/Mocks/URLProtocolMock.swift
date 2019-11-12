//
//  URLProtocolMock.swift
//  TogglWatch Tests
//
//  Created by Ricardo Sánchez Sotres on 11/11/2019.
//  Copyright © 2019 Toggl. All rights reserved.
//

import Foundation

struct StubbedResponse {
    let response: HTTPURLResponse
    let data: Data
}

class URLProtocolMock: URLProtocol
{
    static var urls = [URL: StubbedResponse]()

    override class func canInit(with request: URLRequest) -> Bool
    {
        guard let url = request.url else { return false }
        return urls.keys.contains(url)
    }

    override class func canonicalRequest(for request: URLRequest) -> URLRequest
    {
        return request
    }

    override class func requestIsCacheEquivalent(_: URLRequest, to _: URLRequest) -> Bool
    {
        return false
    }

    override func startLoading()
    {
        guard let client = client, let url = request.url, let mock = URLProtocolMock.urls[url] else
        {
            fatalError()
        }

        client.urlProtocol(self, didReceive: mock.response, cacheStoragePolicy: .notAllowed)
        client.urlProtocol(self, didLoad: mock.data)
        client.urlProtocolDidFinishLoading(self)
    }

    override func stopLoading() {}
}
