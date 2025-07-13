//
//  InputStream+extensions.swift
//  NetworkProviderTests
//
//  Created on __DATEIDENTIFIER__.
//

import Foundation

extension InputStream {
    func asData() -> Data {
        let bufferSize: Int = 16
        let buffer = UnsafeMutablePointer<UInt8>.allocate(capacity: bufferSize)
        var data = Data()

        open()

        while hasBytesAvailable {
            let readData = read(buffer, maxLength: bufferSize)
            data.append(buffer, count: readData)
        }

        buffer.deallocate()
        close()

        return data
    }
}
