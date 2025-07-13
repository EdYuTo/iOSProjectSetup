//
//  NetworkProviderProtocol.swift
//  NetworkProvider
//
//  Created on __DATEIDENTIFIER__.
//

import Foundation

public protocol NetworkProviderProtocol {
    func makeRequest<T: Decodable>(_ request: NetworkRequestProtocol) async throws -> NetworkResponse<T>
    func makeRequest(_ request: NetworkRequestProtocol) async throws -> NetworkResponse<Data>
}
