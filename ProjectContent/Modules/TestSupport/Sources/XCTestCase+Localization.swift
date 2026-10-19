//
//  XCTestCase+Localization.swift
//  TestSupport
//
//  Created by Edson Yudi Toma on 01/02/26.
//

import XCTest

public extension XCTestCase {
    func validateLocalization<T>(
        _ fields: [String: T],
        bundle: Bundle,
        with validation: (T, String) async -> Void
    ) async {
        addTeardownBlock {
            bundle.unsetLocalizedLanguage()
        }

        for (language, expectedField) in fields {
            bundle.setLocalizedLanguage(to: language)
            await validation(expectedField, language)
        }
    }
}
