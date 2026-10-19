//
//  SecureStorageProviderTests.swift
//  CacheProviderTests
//
//  Created on __DATEIDENTIFIER__.
//

import CacheProvider
import CryptoKit
import XCTest

final class SecureStorageProviderTests: XCTestCase {
    func testAccountIsTheHashedKey() async throws {
        var receivedAccount: String?
        let accessor = KeychainAccessorMock()
        let sut = SecureStorageProvider(service: "svc", keychainAccessorProvider: { account in
            receivedAccount = account
            return accessor
        })

        try await sut.set(key: "session", value: "token")

        XCTAssertEqual(receivedAccount, try sha256Hex(of: "session"))
    }

    func testSetThenGetRoundTrips() async throws {
        let (sut, _) = makeSut()
        let session = StoredSession(token: "abc", role: "customer")

        try await sut.set(key: "session", value: session)
        let loaded: StoredSession = try await sut.get(key: "session")

        XCTAssertEqual(loaded, session)
    }

    func testGetMissingThrowsNotFound() async {
        let (sut, _) = makeSut()
        await assertCacheError(try await sut.get(key: "missing") as String) {
            if case .notFound = $0 { return true }
            return false
        }
    }

    func testGetAfterDeleteThrowsNotFound() async throws {
        let (sut, _) = makeSut()
        try await sut.set(key: "session", value: "token")

        try await sut.delete(key: "session")

        await assertCacheError(try await sut.get(key: "session") as String) {
            if case .notFound = $0 { return true }
            return false
        }
    }

    func testGetCorruptDataThrowsDecoding() async {
        let (sut, accessor) = makeSut()
        accessor.store(raw: Data("not json".utf8))
        await assertCacheError(try await sut.get(key: "session") as StoredSession) {
            if case .decoding = $0 { return true }
            return false
        }
    }

    func testKeychainReadFailureOtherThanNotFoundThrowsUnknown() async {
        let (sut, accessor) = makeSut()
        try? await accessor.set(Data("\"token\"".utf8))
        accessor.getError = KeychainError(status: errSecInteractionNotAllowed)
        await assertCacheError(try await sut.get(key: "session") as String) {
            if case .unknown = $0 { return true }
            return false
        }
    }

    func testUnhashableKeyThrowsInvalidKey() async {
        let (sut, _) = makeSut()
        await assertCacheError(try await sut.set(key: ThrowingKey(), value: "x")) {
            if case .invalidKey = $0 { return true }
            return false
        }
    }

    func testKeychainWriteFailureThrowsUnknown() async {
        let (sut, accessor) = makeSut()
        accessor.setError = NSError(domain: "keychain", code: -1)
        await assertCacheError(try await sut.set(key: "session", value: "x")) {
            if case .unknown = $0 { return true }
            return false
        }
    }

    func testKeychainDeleteFailureThrowsUnknown() async {
        let (sut, accessor) = makeSut()
        accessor.deleteError = NSError(domain: "keychain", code: -1)
        await assertCacheError(try await sut.delete(key: "session")) {
            if case .unknown = $0 { return true }
            return false
        }
    }

    // MARK: - Helpers

    private func makeSut() -> (SecureStorageProvider, KeychainAccessorMock) {
        let accessor = KeychainAccessorMock()
        let sut = SecureStorageProvider(service: "svc", keychainAccessorProvider: { _ in accessor })
        return (sut, accessor)
    }

    private func sha256Hex(of key: String) throws -> String {
        let data = try JSONEncoder().encode(key)
        return SHA256.hash(data: data).map { String(format: "%02x", $0) }.joined()
    }

    private func assertCacheError<T>(
        _ operation: @autoclosure () async throws -> T,
        file: StaticString = #filePath,
        line: UInt = #line,
        matching predicate: (CacheError) -> Bool
    ) async {
        do {
            _ = try await operation()
            XCTFail("Expected a CacheError", file: file, line: line)
        } catch let error as CacheError {
            XCTAssertTrue(predicate(error), "Unexpected error \(error)", file: file, line: line)
        } catch {
            XCTFail("Expected CacheError, got \(error)", file: file, line: line)
        }
    }
}

private struct StoredSession: Codable, Equatable {
    let token: String
    let role: String
}

private struct ThrowingKey: Encodable {
    func encode(to encoder: Encoder) throws {
        throw NSError(domain: "ThrowingKey", code: 0)
    }
}
