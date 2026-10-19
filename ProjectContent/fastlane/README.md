fastlane documentation
----

# Installation

Make sure you have the latest version of the Xcode command line tools installed:

```sh
xcode-select --install
```

For _fastlane_ installation instructions, see [Installing _fastlane_](https://docs.fastlane.tools/#installing-fastlane)

# Available Actions

## iOS

### ios makeFramework

```sh
[bundle exec] fastlane ios makeFramework
```

Creates a new framework module under Modules/ and links it into the app

#### Parameters
  * frameworkName - UpperCamelCase module name (required)

#### Example
  bundle exec fastlane makeFramework frameworkName:MyNewModule

### ios generate_project

```sh
[bundle exec] fastlane ios generate_project
```

Fetches dependencies and generates the workspace

#### Optional parameters
  * open: true - Open the workspace after generation

### ios open_project

```sh
[bundle exec] fastlane ios open_project
```

Opens the workspace

### ios test_project

```sh
[bundle exec] fastlane ios test_project
```

Generates the workspace and runs every test bundle

#### Optional parameters
  * open: true - Open the test results after running tests

### ios generate_app

```sh
[bundle exec] fastlane ios generate_app
```

Builds a simulator .xcarchive of the app

#### Optional parameters
  * open: true - Open the archive after generation

### ios clean_project

```sh
[bundle exec] fastlane ios clean_project
```

Removes generated projects and build output

### ios lint_project

```sh
[bundle exec] fastlane ios lint_project
```

Runs SwiftLint over the app and modules

----

This README.md is auto-generated and will be re-generated every time [_fastlane_](https://fastlane.tools) is run.

More information about _fastlane_ can be found on [fastlane.tools](https://fastlane.tools).

The documentation of _fastlane_ can be found on [docs.fastlane.tools](https://docs.fastlane.tools).
