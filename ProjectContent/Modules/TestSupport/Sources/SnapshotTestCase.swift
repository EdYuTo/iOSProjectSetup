//
//  SnapshotTestCase.swift
//  TestSupport
//
//  Created by Edson Yudi Toma on 01/02/26.
//

import UIKit
import XCTest

open class SnapshotTestCase: XCTestCase {
    public var referencePath: URL?
    /// Record instead of verify. Set `TEST_RUNNER_SNAPSHOT_RECORD=1` on `xcodebuild`
    /// (it reaches the test process as `SNAPSHOT_RECORD`).
    public var shouldRecord = ProcessInfo.processInfo.environment["SNAPSHOT_RECORD"] == "1"
    public var overrideUserInterfaceStyle: UIUserInterfaceStyle = .light

    public func verify(
        _ viewController: UIViewController,
        identifier: String? = nil,
        size: CGSize? = nil,
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        verify(viewController.view, identifier: identifier, size: size, file: file, line: line)
    }

    public func verify(
        _ view: UIView,
        identifier: String? = nil,
        size: CGSize? = nil,
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        if let size {
            view.frame = CGRect(origin: .zero, size: size)
        }
        let snapshot = takeSnapshot(view)
        let snapshotData = try? makeSnapshotData(for: snapshot, file: file, line: line)

        if shouldRecord {
            record(
                identifier: identifier,
                data: snapshotData,
                file: file,
                line: line
            )
            return
        }

        guard let referenceUrl = try? getReferencePath(identifier: identifier, file: file, line: line),
              let referenceData = try? Data(contentsOf: referenceUrl) else {
            XCTFail("Failed to load image reference", file: file, line: line)
            return
        }

        if snapshotData != referenceData {
            let temporarySnapshotUrl = URL(fileURLWithPath: NSTemporaryDirectory(), isDirectory: true)
                .appendingPathComponent(referenceUrl.lastPathComponent)

            try? snapshotData?.write(to: temporarySnapshotUrl)

            XCTFail("Images differ, check \(temporarySnapshotUrl.absoluteString) for more info", file: file, line: line)
        }
    }
}

// MARK: - Helpers

private extension SnapshotTestCase {
    func takeSnapshot(_ view: UIView) -> UIImage {
        let window = view.window ?? UIWindow(frame: view.frame)
        if view.window == nil {
            window.rootViewController = UIViewController()
            window.rootViewController?.view = view
        }
        window.overrideUserInterfaceStyle = overrideUserInterfaceStyle
        window.makeKeyAndVisible()
        return window.takeSnapshot()
    }

    func getReferencePath(identifier: String? = nil, file: StaticString, line: UInt) throws -> URL {
        let name = try getImageName(identifier: identifier, file: file, line: line)
        return referencePath ?? URL(fileURLWithPath: String(describing: file))
            .deletingLastPathComponent()
            .appendingPathComponent("Snapshots")
            .appendingPathComponent("\(name).png")
    }

    func makeSnapshotData(for snapshot: UIImage, file: StaticString, line: UInt) throws -> Data {
        let data = snapshot.pngData()
        return try XCTUnwrap(data, "Failed to generate data for snapshot", file: file, line: line)
    }

    func getImageName(identifier: String?, file: StaticString, line: UInt) throws -> String {
        let method = identifier ?? name
            .components(separatedBy: " ")
            .last?
            .trimmingCharacters(in: CharacterSet(charactersIn: "]"))
        let name = try XCTUnwrap(
            method,
            "Unable to extract image name",
            file: file,
            line: line
        )
        return name
    }

    func record(identifier: String?, data: Data?, file: StaticString, line: UInt) {
        do {
            let directory = try getReferencePath(identifier: identifier, file: file, line: line)
            try FileManager.default.createDirectory(
                at: directory.deletingLastPathComponent(),
                withIntermediateDirectories: true
            )

            let data = try XCTUnwrap(data)
            try data.write(to: directory)
            XCTFail("Image saved to \(directory), re run with `shouldRecord = false`", file: file, line: line)
        } catch {
            XCTFail("Failed to save snapshot with error: \(error)", file: file, line: line)
        }
    }
}
