//
//  TimestampedData.swift
//  CacheProvider
//
//  Created on __DATEIDENTIFIER__.
//

import Foundation

public struct TimestampedData<T: Codable>: Codable {
    public let data: T
    public let timestamp: Date

    public init(data: T, timestamp: Date = Date()) {
        self.data = data
        self.timestamp = timestamp
    }
}
