//
//  NetworkResponse.swift
//  NetworkProvider
//
//  Created on __DATEIDENTIFIER__.
//

public struct NetworkResponse<T> {
    public let statusCode: Int
    public let headers: [AnyHashable: Any]
    public let content: T

    public init(statusCode: Int, headers: [AnyHashable: Any], content: T) {
        self.statusCode = statusCode
        self.headers = headers
        self.content = content
    }
}
