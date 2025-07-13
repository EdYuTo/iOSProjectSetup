//
//  CacheProviderTests.swift
//  CacheProviderTests
//
//  Created on __DATEIDENTIFIER__.
//

import CacheProvider
import CryptoKit
import XCTest

final class CacheProviderTests: XCTestCase {
    // MARK: - Get
    func testUrlProperlySetOnGet() async {
        let key = "key"
        let url = URL(string: "path")!
        let hashedKey = hashedKey(key)

        let sut = CacheProvider(storagePath: url, fileAccessorProvider: { newUrl in
            XCTAssertEqual(newUrl, url.appendingPathComponent(hashedKey))
            return FileAccessorMock()
        })
        do {
            let _: String = try await sut.get(key: key)
        } catch {}
    }

    func testInvalidKeyOnGet() async {
        let (sut, _) = makeSut()

        do {
            let _: String = try await sut.get(key: Unencodable())
            XCTFail("Expect to throw an error")
        } catch {
            if let error = error as? CacheError, case .invalidKey = error {} else {
                XCTFail("Should've thrown .invalidKey error, but threw \(error) instead")
            }
        }
    }

    func testEmptyErrorOnGet() async {
        let (sut, _) = makeSut()

        do {
            let _: String = try await sut.get(key: "key")
            XCTFail("Expect to throw an error")
        } catch {
            if let error = error as? CacheError, case .notFound = error {} else {
                XCTFail("Should've thrown .notFound error, but threw \(error) instead")
            }
        }
    }

    func testdecodingOnGet() async throws {
        let (sut, fileAccessor) = makeSut()
        try await fileAccessor.set(Data("not json".utf8))

        do {
            let _: String = try await sut.get(key: "key")
            XCTFail("Expect to throw an error")
        } catch {
            if let error = error as? CacheError, case .decoding = error {} else {
                XCTFail("Should've thrown .decoding error, but threw \(error) instead")
            }
        }
    }

    func testValueShouldBeRecoveredOnGet() async throws {
        let (key, value) = ("key", "value")
        let (sut, _) = makeSut()
        try await sut.set(key: key, value: value)

        do {
            let retrievedValue: String = try await sut.get(key: key)
            XCTAssertEqual(retrievedValue, value)
        } catch {
            XCTFail("Should've retrieved value, but threw \(error) instead")
        }
    }

    // MARK: - Set
    func testUrlProperlySetOnSet() async {
        let key = "key"
        let url = URL(string: "path")!
        let hashedKey = hashedKey(key)

        let sut = CacheProvider(storagePath: url, fileAccessorProvider: { newUrl in
            XCTAssertEqual(newUrl, url.appendingPathComponent(hashedKey))
            return FileAccessorMock()
        })
        do {
            try await sut.set(key: key, value: "")
        } catch {}
    }

    func testInvalidKeyOnSet() async {
        let (sut, _) = makeSut()

        do {
            try await sut.set(key: Unencodable(), value: "value")
            XCTFail("Expect to throw an error")
        } catch {
            if let error = error as? CacheError, case .invalidKey = error {} else {
                XCTFail("Should've thrown .invalidKey error, but threw \(error) instead")
            }
        }
    }

    func testencodingOnSet() async {
        let (sut, _) = makeSut()

        do {
            try await sut.set(key: "key", value: Unencodable())
            XCTFail("Expect to throw an error")
        } catch {
            if let error = error as? CacheError, case .encoding = error {} else {
                XCTFail("Should've thrown .encoding error, but threw \(error) instead")
            }
        }
    }

    func testUnknownErrorOnSet() async {
        let (sut, fileAccessor) = makeSut()
        fileAccessor.setError = NSError(domain: "testUnknownErrorOnSet", code: 0)

        do {
            try await sut.set(key: "key", value: "")
            XCTFail("Expect to throw an error")
        } catch {
            if let error = error as? CacheError, case .unknown = error {} else {
                XCTFail("Should've thrown .unknown error, but threw \(error) instead")
            }
        }
    }

    func testValueShouldBeOverwrittenOnSet() async throws {
        let key = "key"
        let value = "Completely valid value"
        let newValue = "Wow, this is different from before!"
        let (sut, _) = makeSut()

        try await sut.set(key: key, value: value)
        try await sut.set(key: key, value: newValue)

        let retrievedValue: String = try await sut.get(key: key)

        XCTAssertEqual(retrievedValue, newValue, "Read value should match written value.")
    }

    // MARK: - Delete
    func testUrlProperlySetOnDelete() async {
        let key = "key"
        let url = URL(string: "path")!
        let hashedKey = hashedKey(key)

        let sut = CacheProvider(storagePath: url, fileAccessorProvider: { newUrl in
            XCTAssertEqual(newUrl, url.appendingPathComponent(hashedKey))
            return FileAccessorMock()
        })
        do {
            try await sut.delete(key: key)
        } catch {}
    }

    func testInvalidKeyOnDelete() async {
        let (sut, _) = makeSut()

        do {
            try await sut.delete(key: Unencodable())
            XCTFail("Expect to throw an error")
        } catch {
            if let error = error as? CacheError, case .invalidKey = error {} else {
                XCTFail("Should've thrown .invalidKey error, but threw \(error) instead")
            }
        }
    }

    func testUnknownErrorOnDelete() async {
        let (sut, fileAccessor) = makeSut()
        fileAccessor.deleteError = NSError(domain: "testUnknownErrorOnSet", code: 0)

        do {
            try await sut.delete(key: "key")
            XCTFail("Expect to throw an error")
        } catch {
            if let error = error as? CacheError, case .unknown = error {} else {
                XCTFail("Should've thrown .unknown error, but threw \(error) instead")
            }
        }
    }

    func testValueShouldBeRemovedOnDelete() async throws {
        let key = "key"
        let value = "Completely valid value"
        let (sut, fileAccessor) = makeSut()

        try await sut.set(key: key, value: value)
        XCTAssertNotNil(fileAccessor.data)

        try await sut.delete(key: key)
        XCTAssertNil(fileAccessor.data)
    }
}

// MARK: - Helpers
private extension CacheProviderTests {
    func makeSut(
        _ url: URL = URL(fileURLWithPath: #file),
        file: StaticString = #file,
        line: UInt = #line
    ) -> (CacheProviderProtocol, FileAccessorMock) {
        let fileAccessor = FileAccessorMock()
        let cache = CacheProvider(
            storagePath: url,
            fileAccessorProvider: { _ in fileAccessor }
        )
        trackMemoryLeaks(cache)
        trackMemoryLeaks(fileAccessor)
        return (cache, fileAccessor)
    }

    func hashedKey(_ key: Encodable) -> String {
        let data = try! JSONEncoder().encode(key)
        return SHA256.hash(data: data).compactMap { String(format: "%02x", $0) }.joined()
    }

    struct Unencodable: Codable {
        func encode(to encoder: any Encoder) throws {
            throw encoding.invalidValue(
                self,
                encoding.Context(codingPath: [], debugDescription: "Unencodable")
            )
        }
    }
}
