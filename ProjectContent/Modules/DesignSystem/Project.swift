import ProjectDescription
import ProjectDescriptionHelpers

let project = Project.module(
    name: "DesignSystem",
    testDependencies: [.module("TestSupport")],
    additionalTargets: [
        // Catalog app: browse tokens and components on a device, one page per entry.
        .target(
            name: "DesignSystemCatalog",
            destinations: ProjectConfig.destinations,
            product: .app,
            bundleId: "\(ProjectConfig.bundlePrefix).DesignSystemCatalog",
            deploymentTargets: ProjectConfig.deploymentTargets,
            infoPlist: .extendingDefault(with: [
                "CFBundleDisplayName": "Catalog",
                "CFBundleShortVersionString": "$(MARKETING_VERSION)",
                "CFBundleVersion": "$(CURRENT_PROJECT_VERSION)",
                "UILaunchScreen": [:]
            ]),
            sources: ["Catalog/Sources/**"],
            dependencies: [.target(name: "DesignSystem")]
        ),
        .target(
            name: "DesignSystemCatalogTests",
            destinations: ProjectConfig.destinations,
            product: .unitTests,
            bundleId: "\(ProjectConfig.bundlePrefix).DesignSystemCatalogTests",
            deploymentTargets: ProjectConfig.deploymentTargets,
            infoPlist: .default,
            sources: ["Catalog/Tests/**"],
            dependencies: [.target(name: "DesignSystemCatalog")]
        )
    ]
)
