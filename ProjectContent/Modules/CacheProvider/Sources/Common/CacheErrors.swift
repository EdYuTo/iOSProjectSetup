//
//  CacheErrors.swift
//  CacheProvider
//
//  Created on __DATEIDENTIFIER__.
//

public enum CacheError: Error {
    case notFound(key: CacheProviderProtocol.Key)
    case decoding(description: String)
    case encoding(description: String)
    case unknown(description: String)
    case expired
    case invalidKey
}
