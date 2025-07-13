//
//  Dictionary+extensions.swift
//  NetworkProviderTests
//
//  Created on __DATEIDENTIFIER__.
//

import Foundation

extension Dictionary {
    func toNSDictionary() -> NSDictionary {
        return NSDictionary(dictionary: self)
    }
}
