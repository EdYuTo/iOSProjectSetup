//
//  FileAccessorMock.swift
//  CacheProviderTests
//
//  Created on __DATEIDENTIFIER__.
//

import CacheProvider
import XCTest

final class FileAccessorMock: FileAccessorProtocol {
    private(set) var data: Data?
    var getError: Error?
    var setError: Error?
    var deleteError: Error?

    func get() async throws -> Data {
        if let getError {
            throw getError
        }
        guard let data else {
            throw NSError(domain: "No data", code: 500)
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
}
