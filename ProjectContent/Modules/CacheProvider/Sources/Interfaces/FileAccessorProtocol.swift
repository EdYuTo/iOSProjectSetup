//
//  FileAccessorProtocol.swift
//  CacheProvider
//
//  Created on __DATEIDENTIFIER__.
//

import Foundation

public protocol FileAccessorProtocol {
    func get() async throws -> Data
    func set(_ data: Data) async throws
    func delete() async throws
}
