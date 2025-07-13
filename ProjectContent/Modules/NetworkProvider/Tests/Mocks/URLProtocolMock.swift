//
//  URLProtocolMock.swift
//  NetworkProviderTests
//
//  Created on __DATEIDENTIFIER__.
//

import Foundation
import NetworkProvider

final class URLProtocolMock: URLProtocol {
    private static let semaphore = DispatchSemaphore(value: 1)
    static var data: Data?
    static var response: HTTPURLResponse?
    static var error: Error?
    static var request: URLRequest?

    static func setup() {
        semaphore.wait()
    }

    static func tearDown() {
        data = nil
        response = nil
        error = nil
        request = nil
        semaphore.signal()
    }

    override static func canInit(with request: URLRequest) -> Bool {
        true
    }

    override static func canonicalRequest(for request: URLRequest) -> URLRequest {
        Self.request = request
        return request
    }

    override func startLoading() {
        if let error = Self.error {
            client?.urlProtocol(self, didFailWithError: error)
            return
        }

        guard let response = Self.response else {
            client?.urlProtocol(self, didFailWithError: NetworkError.invalidResponse)
            return
        }

        if let data = Self.data {
            client?.urlProtocol(self, didLoad: data)
        }

        client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .allowed)
        client?.urlProtocolDidFinishLoading(self)
    }

    override func stopLoading() {}
}
