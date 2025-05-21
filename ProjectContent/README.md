# __PROJECTNAMEIDENTIFIER__

## Dependencies
This projects uses [Xcodegen](https://github.com/yonaskolb/XcodeGen), [Fastlane](https://fastlane.tools/) and [Bundler](https://bundler.io/) to minimize your time setting up everything! It also has [Swiftlint](https://realm.github.io/SwiftLint/) to ensure code coding style and conventions.

Please use `Xcode 16` to run this.

### Why those?
[Xcodegen](https://github.com/yonaskolb/XcodeGen) is a good choice when wroking in big repos because it removes the need for pushing `.xcodeproj` and `.xcworkspace` to remote. This is possible thanks to the way it works, we provide a configuration file (`project.yml`) that is used to generate `.xcodeproj` files on the fly!
There are other alternatives too, one that work particulary well with SPM is called [Tuist](https://tuist.dev/)

[Fastlane](https://fastlane.tools/) is just awesome, it's a really powerful tool that allow creating `lanes` for each job your pipeline might need. If you see my other [test repo](https://github.com/EdYuTo/iOSProjectSetup) you'll see that i did basically the same github actions configurations as here, but using `Makefile`. You'll also see that it was necessary a couple of extra scripts to achieve what was possible with just one file with `Fastlane`.

[Bundler](https://bundler.io/) was used to ensure all machines run under the same dependencies. It's super annoying when the code `works on my machine`, but you can't get it to run on someone else's. In theory, if we all run with the same conditions, the project should work just fine for everybody!

In the same line as `Bundler`, other awesome tools that we could use are [Xcodes](https://www.xcodes.app/) for managing xcode versions and [rbenv](https://rbenv.org/) to manage different ruby versions (specially for our fastlane gems!).

[Swiftlint](https://realm.github.io/SwiftLint/) is used to ensure a codebase consistency and clarity.

## Setup

Although this is not required, it is highly recommended to use [rbenv](https://rbenv.org/) to manage your ruby environment:

```bash
brew install rbenv
```

```bash
rbenv install 3.2.0
```

```bash
rbenv local 3.2.0
```

First install any missing dependencies with:
```bash
bundle install
```

Then run fastlane to create the project:
```bash
bundle exec fastlane generate_project
```

## TBD
Update as you please
