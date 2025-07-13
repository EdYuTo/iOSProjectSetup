//
//  DebugLoggerProtocol.swift
//  DebugLoggerProvider
//
//  Created on __DATEIDENTIFIER__.
//

public protocol DebugLoggerProtocol {
    func logInfo(_ message: String, args: CVarArg...)
    func logError(_ message: String, args: CVarArg...)
    func logWarning(_ message: String, args: CVarArg...)
}
