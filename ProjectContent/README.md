# __PROJECTNAMEIDENTIFIER__

## Dependencies
This project uses [Tuist](https://tuist.dev/), [mise](https://mise.jdx.dev), [Fastlane](https://fastlane.tools/) and [Bundler](https://bundler.io/) to minimize your time setting up everything! It also has [Swiftlint](https://realm.github.io/SwiftLint/) to enforce coding style and conventions.

Please use `Xcode 26` (iOS 26.0+ deployment target) to run this. CI runs on `macos-26` with Xcode `26.6`.

### Why those?
[Tuist](https://tuist.dev/) generates the Xcode workspace from Swift manifests (`Project.swift` per project, `Workspace.swift`), so no `.xcodeproj` or `.xcworkspace` is committed. Each module declares its own dependencies, and Tuist works out the build order from that graph: there is no list of modules to keep in order by hand. Swift packages are declared once in `Tuist/Package.swift`.

[mise](https://mise.jdx.dev) pins the Tuist and SwiftLint versions in `.mise.toml`, so every machine and CI run uses the same ones.

[Fastlane](https://fastlane.tools/) is just awesome, it's a really powerful tool that allow creating `lanes` for each job your pipeline might need.

[Bundler](https://bundler.io/) was used to ensure all machines run under the same dependencies. It's super annoying when the code `works on my machine`, but you can't get it to run on someone else's. In theory, if we all run with the same conditions, the project should work just fine for everybody!

[Swiftlint](https://realm.github.io/SwiftLint/) is used to ensure a codebase consistency and clarity.

## Setup

Although this is not required, it is highly recommended to use [rbenv](https://rbenv.org/) to manage your ruby environment:

```bash
brew install rbenv
```

```bash
rbenv install $(cat .ruby-version)
```

> [!TIP]
> If `rbenv` doesn't know the version yet, update its definitions with `brew upgrade ruby-build`.

Install [mise](https://mise.jdx.dev), then the pinned tools:
```bash
brew install mise
mise trust && mise install
```

Install the gems:
```bash
bundle install
```

Then run fastlane to create the workspace:
```bash
bundle exec fastlane generate_project
```

## Lanes

| Command | What it does |
|---|---|
| `bundle exec fastlane generate_project [open:false]` | `tuist install` + `tuist generate`, stamping the version from `version` |
| `bundle exec fastlane test_project [open:false]` | Generates, then runs every test bundle (the `__PROJECTNAMEIDENTIFIER__-Workspace` scheme) |
| `bundle exec fastlane lint_project` | SwiftLint over the app and `Modules/` |
| `bundle exec fastlane generate_app [open:false]` | Release simulator `.xcarchive` in `build/` |
| `bundle exec fastlane clean_project` | Removes generated projects and build output |
| `bundle exec fastlane makeFramework frameworkName:Name` | Scaffolds `Modules/Name` and links it into the app |

## Layout

- `Project.swift`: the app and its tests. `Workspace.swift` adds every `Modules/*` project.
- `Tuist/ProjectDescriptionHelpers`: shared settings (`ProjectConfig`), `Project.module(...)`, and the app's module list (`AppModules.swift`).
- `Modules/`:
  - `NetworkProvider`: async `URLSession` client with path parameters, an injectable session, and a dedicated error for cancelled requests.
  - `CacheProvider`: file cache with expiry, plus `SecureStorageProvider` backed by the Keychain.
  - `DebugLoggerProvider`: debug logging helpers.
  - `TestSupport`: linked by test bundles only; `SnapshotTestCase` gives snapshot tests without third-party code.
  - `DesignSystem`: shared tokens and components, with the `DesignSystemCatalog` app to browse them.

### Adding a module

```bash
bundle exec fastlane makeFramework frameworkName:MyModule
bundle exec fastlane generate_project
```

The module gets its own `Project.swift`, and one line is added to `Tuist/ProjectDescriptionHelpers/AppModules.swift`. A module that depends on another lists it in its manifest, `Project.module(name: "MyModule", dependencies: [.module("NetworkProvider")])`, and Tuist orders the build.

### Snapshot tests

Subclass `SnapshotTestCase` (from `TestSupport`) and call `verify(view)`. Record references with `Scripts/snapshots.sh record <Scheme> <TestTarget/TestClass>`, then check them with `Scripts/snapshots.sh verify …`.

## TBD
Update as you please
