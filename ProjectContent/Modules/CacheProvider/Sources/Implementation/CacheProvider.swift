//
//  CacheProvider.swift
//  CacheProvider
//
//  Created on __DATEIDENTIFIER__.
//

import Foundation

public final class CacheProvider {
    private let storagePath: URL
    private let fileAccessorProvider: (URL) -> FileAccessorProtocol

    public init(
        storagePath: URL,
        fileAccessorProvider: @escaping (URL) -> FileAccessorProtocol = { FileAccessor(fileUrl: $0) }
    ) {
        self.storagePath = storagePath
        self.fileAccessorProvider = fileAccessorProvider
    }
}

// MARK: - CacheProviderProtocol
extension CacheProvider: CacheProviderProtocol {
    public func get<T: Codable>(key: Key) async throws -> T {
        let accessor = try getFileAccessor(forKey: key)
        guard let data = try? await accessor.get() else {
            throw CacheError.notFound(key: key)
        }
        do {
            let decoder = JSONDecoder()
            let object = try decoder.decode(T.self, from: data)
            return object
        } catch {
            throw CacheError.decoding(description: error.localizedDescription)
        }
    }

    public func set<T: Codable>(key: Key, value: T) async throws {
        let accessor = try getFileAccessor(forKey: key)
        do {
            let encoder = JSONEncoder()
            let data = try encoder.encode(value)
            try await accessor.set(data)
        } catch let error as Swift.encoding {
            throw CacheError.encoding(description: error.localizedDescription)
        } catch {
            throw CacheError.unknown(description: error.localizedDescription)
        }
    }

    public func delete(key: Key) async throws {
        let accessor = try getFileAccessor(forKey: key)
        do {
            try await accessor.delete()
        } catch {
            throw CacheError.unknown(description: error.localizedDescription)
        }
    }
}

// MARK: - Helpers
private extension CacheProvider {
    func getFileAccessor(forKey key: Key) throws -> FileAccessorProtocol {
        guard let hashedKey = key.cacheKey else {
            throw CacheError.invalidKey
        }
        let url = storagePath.appendingPathComponent(hashedKey)
        return fileAccessorProvider(url)
    }
}
