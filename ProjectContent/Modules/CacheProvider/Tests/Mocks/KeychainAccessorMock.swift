//
//  KeychainAccessorMock.swift
//  CacheProviderTests
//
//  Created on __DATEIDENTIFIER__.
//

import CacheProvider
import Foundation

final class KeychainAccessorMock: KeychainAccessorProtocol {
    private(set) var data: Data?
    var getError: Error?
    var setError: Error?
    var deleteError: Error?

    func get() async throws -> Data {
        if let getError {
            throw getError
        }
        guard let data else {
            throw KeychainError(status: errSecItemNotFound)
        }
        return data
    }

    func set(_ data: Data) async throws {
        if let setError {
            throw setError
        }
        self.data = data
    }

    func delete() async throws {
        if let deleteError {
            throw deleteError
        }
        data = nil
    }

    func store(raw data: Data) {
        self.data = data
    }
}
