# What is this?
A generator for a starter iOS project with some basic configurations. It asks for a project name, bundle prefix and (optionally) your development team, then creates a ready to use repo in the current directory.

Every flavor ships with:
* Starting **SwiftUI** project with `Hello World!`, UnitTests and UITests
* [XcodeGen](https://github.com/yonaskolb/XcodeGen) spec (`project.yml`), no `.xcodeproj` is committed
* Base [SwiftLint](https://realm.github.io/SwiftLint/) config
* GitHub Actions to lint and test pull requests, and to build an `.app` + tag a release on `main` (iOS simulator only, it is not integrated with provisioning and signing)

Requirements: **Xcode 26** (iOS 26.0+ deployment target). CI runs on `macos-26` with Xcode `26.6`.

# Flavors
Each branch of this repo is a different flavor of the template, pick the one that fits you (this README is on `main`):

| Branch | Tooling | What you get |
| --- | --- | --- |
| [`main`](https://github.com/EdYuTo/iOSProjectSetup/tree/main) | `Makefile` | Lightest setup. Needs `xcodegen` and `swiftlint` installed (e.g. via Homebrew) |
| [`fastlane`](https://github.com/EdYuTo/iOSProjectSetup/tree/fastlane) | [Fastlane](https://fastlane.tools/) + [Bundler](https://bundler.io/) | Lanes for generating, testing and archiving. XcodeGen and SwiftLint binaries are vendored in `Scripts`, ruby version pinned in `.ruby-version` |
| [`core-modules`](https://github.com/EdYuTo/iOSProjectSetup/tree/core-modules) | Everything in `fastlane` | Plus local framework modules (`CacheProvider`, `DebugLoggerProvider`, `NetworkProvider`) and a `makeFramework` lane to scaffold new ones |

# How to run?
Run this in the directory where the project should be created, it generates the `main` flavor:
```shell
sh -c "$(curl -fsSL https://raw.githubusercontent.com/EdYuTo/iOSProjectSetup/main/setup.sh)"
```

For another flavor, use the command from that branch's README.

# What's next?
* Integrate the release action with signing and TestFlight
* More templates? Improved base project.
