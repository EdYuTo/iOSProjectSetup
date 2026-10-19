//
//  Bundle+Localization.swift
//  TestSupport
//
//  Created by Edson Yudi Toma on 01/02/26.
//

import Foundation

public extension Bundle {
    func setLocalizedLanguage(to language: String) {
        guard let path = path(forResource: language, ofType: "lproj"),
              let newBundle = Bundle(path: path) else { return }
        object_setClass(self, CustomLocalizedBundle.self)
        objc_setAssociatedObject(self, &Bundle.bundleKey, newBundle, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
    }

    func unsetLocalizedLanguage() {
        objc_setAssociatedObject(self, &Bundle.bundleKey, nil, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
    }
}

// MARK: - Custom types
private extension Bundle {
    static var bundleKey: UInt8 = 0

    final class CustomLocalizedBundle: Bundle, @unchecked Sendable {
        override func localizedString(forKey key: String, value: String?, table tableName: String?) -> String {
            if let customBundle = objc_getAssociatedObject(self, &Bundle.bundleKey) as? Bundle {
                customBundle.localizedString(forKey: key, value: value, table: tableName)
            } else {
                super.localizedString(forKey: key, value: value, table: tableName)
            }
        }
    }
}
