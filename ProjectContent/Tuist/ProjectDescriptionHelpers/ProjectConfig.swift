import ProjectDescription

/// Values shared by every project in the workspace.
public enum ProjectConfig {
    public static let name = "__PROJECTNAMEIDENTIFIER__"
    public static let bundlePrefix = "__PROJECTBUNDLEPREFIX__"
    public static let developmentTeam = "__PROJECTDEVELOPMENTTEAM__"
    public static let destinations: Destinations = [.iPhone]
    public static let deploymentTargets: DeploymentTargets = .iOS("26.0")

    /// fastlane passes the values from the `version` file through these variables.
    public static let marketingVersion = Environment.marketingVersion.getString(default: "0.1.0")
    public static let buildNumber = Environment.buildNumber.getString(default: "1")

    public static let projectSettings: Settings = .settings(
        base: [
            "SWIFT_VERSION": "5",
            "ENABLE_USER_SCRIPT_SANDBOXING": "NO",
            "SWIFT_EMIT_LOC_STRINGS": "NO",
            "LOCALIZED_STRING_SWIFTUI_SUPPORT": "NO",
            "TARGETED_DEVICE_FAMILY": "1",
            "MARKETING_VERSION": .string(marketingVersion),
            "CURRENT_PROJECT_VERSION": .string(buildNumber),
            "CODE_SIGN_STYLE": "Automatic",
            "DEVELOPMENT_TEAM": .string(developmentTeam)
        ],
        configurations: [
            .debug(name: .debug),
            .release(name: .release, settings: ["SWIFT_COMPILATION_MODE": "wholemodule"])
        ]
    )
}
