import ProjectDescription
import ProjectDescriptionHelpers

// Linked only by test bundles. It links XCTest itself, so it must never be added to `appModules`.
let project = Project.module(
    name: "TestSupport",
    dependencies: [.xctest],
    hasTests: false,
    settings: ["ENABLE_TESTING_SEARCH_PATHS": "YES"]
)
