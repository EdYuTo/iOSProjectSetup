//
//  NetworkRequest.swift
//  NetworkProvider
//
//  Created on __DATEIDENTIFIER__.
//

import Foundation

public struct NetworkRequest: NetworkRequestProtocol {
    public var endpoint: String
    public var body: Data?
    public var httpMethod: HTTPMethod
    public var queryParams: [String: String]?
    public var headers: [String: String]?
    public var decoder: JSONDecoder

    public init(
        endpoint: String,
        body: Data? = nil,
        httpMethod: HTTPMethod = .get,
        queryParams: [String : String]? = nil,
        headers: [String : String]? = nil,
        decoder: JSONDecoder = JSONDecoder()
    ) {
        self.endpoint = endpoint
        self.body = body
        self.httpMethod = httpMethod
        self.queryParams = queryParams
        self.headers = headers
        self.decoder = decoder
    }
}
