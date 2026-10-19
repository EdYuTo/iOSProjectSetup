//
//  CatalogTests.swift
//  DesignSystemCatalogTests
//
//  Created on __DATEIDENTIFIER__.
//

@testable import DesignSystemCatalog
import XCTest

final class CatalogTests: XCTestCase {
    func testEntryIdsAreUnique() {
        let ids = CatalogEntry.all.map(\.id)
        XCTAssertEqual(Set(ids).count, ids.count, "Each catalog entry needs its own id")
    }
}
