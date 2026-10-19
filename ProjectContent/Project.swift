import ProjectDescription
import ProjectDescriptionHelpers

let project = Project(
    name: ProjectConfig.name,
    settings: ProjectConfig.projectSettings,
    targets: [
        .target(
            name: ProjectConfig.name,
            destinations: ProjectConfig.destinations,
            product: .app,
            bundleId: "\(ProjectConfig.bundlePrefix).\(ProjectConfig.name)",
            deploymentTargets: ProjectConfig.deploymentTargets,
            infoPlist: .file(path: "\(ProjectConfig.name)/Resources/Info.plist"),
            sources: ["\(ProjectConfig.name)/**/*.swift"],
            resources: ["\(ProjectConfig.name)/Resources/**/*.xcassets"],
            scripts: [
                .post(script: "\"${SRCROOT}/Scripts/lint.sh\"", name: "SwiftLint", basedOnDependencyAnalysis: false)
            ],
            dependencies: appModules
        ),
        .target(
            name: "\(ProjectConfig.name)Tests",
            destinations: ProjectConfig.destinations,
            product: .unitTests,
            bundleId: "\(ProjectConfig.bundlePrefix).\(ProjectConfig.name)Tests",
            deploymentTargets: ProjectConfig.deploymentTargets,
            infoPlist: .default,
            sources: ["\(ProjectConfig.name)Tests/**"],
            dependencies: [
                .target(name: ProjectConfig.name),
                .module("TestSupport")
            ]
        ),
        .target(
            name: "\(ProjectConfig.name)UITests",
            destinations: ProjectConfig.destinations,
            product: .uiTests,
            bundleId: "\(ProjectConfig.bundlePrefix).\(ProjectConfig.name)UITests",
            deploymentTargets: ProjectConfig.deploymentTargets,
            infoPlist: .default,
            sources: ["\(ProjectConfig.name)UITests/**"],
            dependencies: [.target(name: ProjectConfig.name)]
        )
    ]
)
