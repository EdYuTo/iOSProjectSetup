//
//  FileAccessorTests.swift
//  CacheProviderTests
//
//  Created on __DATEIDENTIFIER__.
//

import CacheProvider
import XCTest

final class FileAccessorTests: XCTestCase {
    override func tearDown() {
        super.tearDown()
        deleteTestStorage()
    }

    // MARK: - Get
    func testEmptyStorageShouldThrowOnGet() async {
        let sut = makeSut()

        do {
            _ = try await sut.get()
            XCTFail("Expect to throw an error")
        } catch {}
    }

    func testInvalidPathShouldThrowOnGet() async {
        let invalidUrl = URL(string: "invalid://store-url")
        let sut = makeSut(fileUrl: invalidUrl)

        do {
            _ = try await sut.get()
            XCTFail("Expect to throw an error")
        } catch {}
    }

    func testDataShouldBeRecoveredOnGet() async throws {
        let data = "Completely valid data".data(using: .utf8)!
        let sut = makeSut()

        try await sut.set(data)
        let retrievedData = try await sut.get()

        XCTAssertEqual(retrievedData, data, "Read data should match written data.")
    }

    // MARK: - Set
    func testInvalidPathShouldThrowOnSet() async {
        let invalidUrl = URL(string: "invalid://store-url")
        let sut = makeSut(fileUrl: invalidUrl)

        do {
            try await sut.set(Data())
            XCTFail("Expect to throw an error")
        } catch {}
    }

    func testDataShouldBeOverwrittenOnSet() async throws {
        let data = "Completely valid data".data(using: .utf8)!
        let newData = "Wow, this is different from before!".data(using: .utf8)!
        let sut = makeSut()

        try await sut.set(data)
        try await sut.set(newData)

        let retrivedData = try await sut.get()

        XCTAssertEqual(retrivedData, newData, "Read data should match written data.")
    }

    // MARK: - Delete
    func testInvalidPathShouldThrowOnDelete() async {
        let invalidUrl = URL(string: "invalid://store-url")
        let sut = makeSut(fileUrl: invalidUrl)

        do {
            try await sut.delete()
            XCTFail("Expect to throw an error")
        } catch {}
    }

    func testDataShouldBeRemovedOnDelete() async throws {
        let data = "Completely valid data".data(using: .utf8)!
        let sut = makeSut()

        try await sut.set(data)
        XCTAssertTrue(FileManager.default.fileExists(atPath: testFileUrl().path))

        try await sut.delete()
        XCTAssertFalse(FileManager.default.fileExists(atPath: testFileUrl().path))
    }
}

// MARK: - Helpers
private extension FileAccessorTests {
    func makeSut(
        fileUrl: URL? = nil,
        file: StaticString = #file,
        line: UInt = #line
    ) -> FileAccessorProtocol {
        let accessor = FileAccessor(fileUrl: fileUrl ?? testFileUrl())
        trackMemoryLeaks(accessor, file: file, line: line)
        return accessor
    }

    func testFileUrl() -> URL {
        FileManager.default.urls(
            for: .cachesDirectory,
            in: .userDomainMask
        ).first!.appendingPathComponent("\(type(of: self)).store")
    }

    func deleteTestStorage(fileUrl: URL? = nil) {
        try? FileManager.default.removeItem(at: fileUrl ?? testFileUrl())
    }

    func cacheDirectory() -> URL {
        FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!
    }
}
