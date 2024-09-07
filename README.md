# What is this?
This is a simple startup project with some basic configurations

It has:
* Starting **SwiftUI** project with `Hello World!`, UnitTests and UITests
* Project configuration files
* Base swiftlint config
* Testing action
* Swiftlint action
* XCFramework + tag generation action (only for iossimulator, it is not integrated with provisioning and signing)

What it needs:
* Actions integrated with fastlane (to upload to testflight, etc)
* More templates? Improved base project.

# How to run?
```shell
sh -c "$(curl -fsSL https://raw.githubusercontent.com/EdYuTo/iOSProjectSetup/main/setup.sh)"
```
