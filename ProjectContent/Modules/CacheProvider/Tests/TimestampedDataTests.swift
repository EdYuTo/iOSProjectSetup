//
//  TimestampedDataTests.swift
//  CacheProviderTests
//
//  Created on __DATEIDENTIFIER__.
//

import CacheProvider
import XCTest

final class TimestampedDataTests: XCTestCase {
    func testTimestampEncoding() {
        let data = "This is just a string"
        let timestamp = Date(timeIntervalSince1970: 1751990290)
        let expectation = expectation(description: "testTimestampEncoding")

        let sut = TimestampedData(data: data, timestamp: timestamp)
        let encodedSut = try! JSONEncoder().encode(sut)

        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            let decodedSut: TimestampedData<String> = try! JSONDecoder().decode(TimestampedData.self, from: encodedSut)
            XCTAssertEqual(decodedSut.data, data)
            XCTAssertEqual(decodedSut.timestamp, timestamp)
            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 3)
    }
}
