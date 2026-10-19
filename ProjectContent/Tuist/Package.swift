// swift-tools-version: 5.9
import PackageDescription

#if TUIST
import ProjectDescription

// Link external packages as dynamic frameworks so app and module targets can share them, e.g.
// productTypes: ["RxSwift": .framework]
let packageSettings = PackageSettings(
    productTypes: [:]
)
#endif

// Add Swift packages here, then reference them from a manifest with `.external(name: "Product")`.
// `bundle exec fastlane generate_project` runs `tuist install` to fetch them.
let package = Package(
    name: "__PROJECTNAMEIDENTIFIER__Dependencies",
    dependencies: []
)
