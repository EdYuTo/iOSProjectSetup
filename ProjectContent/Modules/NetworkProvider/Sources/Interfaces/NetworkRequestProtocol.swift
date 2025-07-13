//
//  NetworkRequestProtocol.swift
//  NetworkProvider
//
//  Created on __DATEIDENTIFIER__.
//

import Foundation

public protocol NetworkRequestProtocol {
    var endpoint: String { get }
    var body: Data? { get }
    var httpMethod: HTTPMethod { get }
    var queryParams: [String: String]? { get }
    var headers: [String: String]? { get }
    var decoder: JSONDecoder { get }
}
