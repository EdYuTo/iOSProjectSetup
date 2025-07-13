//
//  DebugLogger.swift
//  DebugLoggerProvider
//
//  Created on __DATEIDENTIFIER__.
//

import os

public final class DebugLogger {
    private let subsystem: String
    private let category: String
    private lazy var logSystem = OSLog(subsystem: subsystem, category: category)

    public init(subsystem: String, category: String) {
        self.subsystem = subsystem
        self.category = category
    }
}

// MARK: - DebugLoggerProtocol
extension DebugLogger: DebugLoggerProtocol {
    public func logInfo(_ message: String, args: CVarArg...) {
        let message = String(format: message, args)
        log(type: .info, message: message)
    }

    public func logError(_ message: String, args: CVarArg...) {
        let message = String(format: message, args)
        log(type: .fault, message: message)
    }

    public func logWarning(_ message: String, args: CVarArg...) {
        let message = String(format: message, args)
        log(type: .error, message: message)
    }
}

// MARK: - Helpers
private extension DebugLogger {
    func log(type: OSLogType, message: String) {
        #if DEBUG
        os_log(type, log: logSystem, "%@", message)
        #endif
    }
}
