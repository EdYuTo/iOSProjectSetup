//
//  NetworkRequestProtocol.swift
//  NetworkProvider
//
//  Created on __DATEIDENTIFIER__.
//

import Foundation

public protocol NetworkRequestProtocol {
    var endpoint: String { get }
    var pathParams: [String: String]? { get }
    var body: Data? { get }
    var httpMethod: HTTPMethod { get }
    var queryParams: [String: String]? { get }
    var headers: [String: String]? { get }
    var cachePolicy: URLRequest.CachePolicy { get }
    var decoder: JSONDecoder { get }
}

public extension NetworkRequestProtocol {
    var cachePolicy: URLRequest.CachePolicy { .useProtocolCachePolicy }
    var pathParams: [String: String]? { nil }
}
