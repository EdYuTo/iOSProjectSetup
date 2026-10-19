import ProjectDescription

extension Project {
    /// A local framework module at `Modules/<name>` with sources in `Sources/`
    /// and, optionally, an unhosted unit test bundle with sources in `Tests/`.
    /// `additionalTargets` lets a module ship extras such as a sample app.
    public static func module(
        name: String,
        dependencies: [TargetDependency] = [],
        testDependencies: [TargetDependency] = [],
        hasTests: Bool = true,
        settings: SettingsDictionary = [:],
        additionalTargets: [Target] = []
    ) -> Project {
        var targets: [Target] = [
            .target(
                name: name,
                destinations: ProjectConfig.destinations,
                product: .framework,
                bundleId: "\(ProjectConfig.bundlePrefix).\(name)",
                deploymentTargets: ProjectConfig.deploymentTargets,
                infoPlist: .default,
                sources: ["Sources/**"],
                dependencies: dependencies,
                settings: .settings(base: settings)
            )
        ]

        if hasTests {
            targets.append(
                .target(
                    name: "\(name)Tests",
                    destinations: ProjectConfig.destinations,
                    product: .unitTests,
                    bundleId: "\(ProjectConfig.bundlePrefix).\(name)Tests",
                    deploymentTargets: ProjectConfig.deploymentTargets,
                    infoPlist: .default,
                    sources: ["Tests/**"],
                    dependencies: [.target(name: name)] + testDependencies
                )
            )
        }

        return Project(name: name, settings: ProjectConfig.projectSettings, targets: targets + additionalTargets)
    }
}
