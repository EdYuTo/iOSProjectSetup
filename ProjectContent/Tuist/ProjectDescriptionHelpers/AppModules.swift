import ProjectDescription

/// Local framework modules linked into the app target.
/// `fastlane makeFramework` inserts new modules above the marker line, so keep it.
public let appModules: [TargetDependency] = [
    .module("CacheProvider"),
    .module("DebugLoggerProvider"),
    .module("NetworkProvider"),
    .module("DesignSystem"),
    // makeFramework:insert
]

extension TargetDependency {
    /// A local module at `Modules/<name>`, usable from any manifest in the workspace.
    public static func module(_ name: String) -> TargetDependency {
        .project(target: name, path: .relativeToRoot("Modules/\(name)"))
    }
}
