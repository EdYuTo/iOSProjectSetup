//
//  SecureStorageProviderProtocol.swift
//  CacheProvider
//
//  Created on __DATEIDENTIFIER__.
//

import Foundation

/// Storage for secrets (tokens, credentials). It's a separate type from `CacheProviderProtocol`
/// on purpose, so the plain file cache can never be injected where secure storage is required.
public protocol SecureStorageProviderProtocol {
    typealias Key = Encodable

    func get<T: Codable>(key: Key) async throws -> T
    func set<T: Codable>(key: Key, value: T) async throws
    func delete(key: Key) async throws
}
