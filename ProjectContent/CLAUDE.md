# __PROJECTNAMEIDENTIFIER__: working agreements for agents

## Build and test

- Generate the workspace with `bundle exec fastlane generate_project open:false` (Tuist via mise). Never commit `.xcodeproj` or `.xcworkspace`.
- `bundle exec fastlane test_project open:false` runs every test bundle; `bundle exec fastlane lint_project` must stay at zero warnings (CI lints with `--strict`).
- New module: `bundle exec fastlane makeFramework frameworkName:Name`, then regenerate. Declare module-to-module dependencies in the module's `Project.swift`; never maintain a build order by hand.

## Verify in the running app

- Before claiming a UI change works, prove it in the simulator with the `verify-app` skill (`.claude/skills/verify-app/bin/app-ctl`): build, launch, drive by accessibility identifier, and capture a screenshot or recording. A green unit test is not proof of a UI change.
- Find elements by **accessibility identifier only** (`<screen>.<element>[.<qualifier>]`). If a view you need has none, add one; don't drive by coordinates or labels.
- Every flow you verify live also gets an XCUITest using the same identifiers. Appium is for exploration; XCUITest is the regression suite.

## Keep the feature map current

- `.claude/skills/verify-app/features/` has one small file per user-facing feature, indexed by `features/README.md`. **Every new or changed feature updates its file in the same change**, after driving it live.
- Run `/maintain-verification-skill` regularly to audit the map and the `app-ctl` harness against the code and the running app. It edits only the verification skill; app regressions it finds are reported, not papered over.

See `docs/adr/0001-live-verification-and-feature-map.md` for why it works this way.
