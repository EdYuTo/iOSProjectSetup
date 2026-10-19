//
//  SecureStorageProvider.swift
//  CacheProvider
//
//  Created on __DATEIDENTIFIER__.
//

import Foundation

public final class SecureStorageProvider {
    private let keychainAccessorProvider: (String) -> KeychainAccessorProtocol

    /// - Parameters:
    ///   - service: Keychain service name, usually the app's bundle identifier.
    ///   - keychainAccessorProvider: Builds an accessor for a hashed key. Override in tests.
    public init(
        service: String,
        keychainAccessorProvider: ((String) -> KeychainAccessorProtocol)? = nil
    ) {
        self.keychainAccessorProvider = keychainAccessorProvider ?? { account in
            KeychainAccessor(service: service, account: account)
        }
    }
}

// MARK: - SecureStorageProviderProtocol
extension SecureStorageProvider: SecureStorageProviderProtocol {
    public func get<T: Codable>(key: Key) async throws -> T {
        let accessor = try getKeychainAccessor(forKey: key)
        let data: Data
        do {
            data = try await accessor.get()
        } catch let error as KeychainError where error.status == errSecItemNotFound {
            throw CacheError.notFound(key: key)
        } catch {
            // Anything else (e.g. errSecInteractionNotAllowed before first unlock) is not "missing":
            // callers must not treat it as an empty store and discard a valid session.
            throw CacheError.unknown(description: String(describing: error))
        }
        do {
            return try JSONDecoder().decode(T.self, from: data)
        } catch {
            throw CacheError.decoding(description: error.localizedDescription)
        }
    }

    public func set<T: Codable>(key: Key, value: T) async throws {
        let accessor = try getKeychainAccessor(forKey: key)
        let data: Data
        do {
            data = try JSONEncoder().encode(value)
        } catch {
            throw CacheError.encoding(description: error.localizedDescription)
        }
        do {
            try await accessor.set(data)
        } catch {
            throw CacheError.unknown(description: error.localizedDescription)
        }
    }

    public func delete(key: Key) async throws {
        let accessor = try getKeychainAccessor(forKey: key)
        do {
            try await accessor.delete()
        } catch {
            throw CacheError.unknown(description: error.localizedDescription)
        }
    }
}

// MARK: - Helpers
private extension SecureStorageProvider {
    func getKeychainAccessor(forKey key: Key) throws -> KeychainAccessorProtocol {
        guard let hashedKey = key.cacheKey else {
            throw CacheError.invalidKey
        }
        return keychainAccessorProvider(hashedKey)
    }
}
