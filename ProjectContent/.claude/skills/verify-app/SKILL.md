---
name: verify-app
description: "Drive __PROJECTNAMEIDENTIFIER__ and the DesignSystem catalog in the iOS simulator through Appium to prove behavior: launch, health-check, tap and type by accessibility identifier, read the accessibility tree, and capture screenshots and video. Use when verifying any UI change, reproducing a bug, or before claiming a feature works."
---

# Verify __PROJECTNAMEIDENTIFIER__

Drive the real apps in the iOS simulator through Appium's XCUITest driver, and capture evidence. The simulator is `test_device` from `.actions.yml` (the one `fastlane test_project` uses) on the newest installed iOS runtime. Every command is `.claude/skills/verify-app/bin/app-ctl <command>` and prints one JSON object. Run `app-ctl --help` for the full surface, and `<command> --help` for one command. Below, `B` means that path:

```bash
B=.claude/skills/verify-app/bin/app-ctl
```

The first run installs the harness's pinned Node dependencies (Appium, the XCUITest driver, WebdriverIO) into `harness/node_modules`. It needs Node 22 or newer.

## Launch

```bash
$B simulator boot
$B build --app app                 # or: --app catalog (rebuild after any Swift change)
$B launch --app app                # add --args "-flag value" to pass launch arguments
```

`launch` is ready when it returns a `sessionId`. It always terminates and reinstalls the app you just built, so launch arguments take effect every time. Read them in the app with `ProcessInfo.processInfo.arguments` (or `UserDefaults` for `-key value` pairs); a common pattern is a `-resetState` argument that starts the app from a clean slate. `--fresh` also resets the app's data. The first session on a machine builds WebDriverAgent, which takes about 3 minutes; later sessions take under a minute.

## Doctor

`$B doctor` is read-only. Run it first, and again whenever something surprises you. `ok: false` means a *required* check failed: Xcode, the simulator, harness deps, or an `xcodebuild test` fighting for the simulator. Each failing check carries a `fix` command. `build:<app>` reports `STALE` when a source file changed after the app was built: a proof against a stale build is not evidence.

## Drive

- Find everything by **accessibility identifier** (`<screen>.<element>[.<qualifier>]`, for example `home.greeting`): `$B tap <id>`, `$B type <id> <text>`, `$B clear <id>`, `$B swipe <id> left`, `$B wait <id> [--gone] [--timeout <s>]`.
- Three system controls have no identifier of ours, so they get their own commands:
  - `$B back` taps the navigation bar's back button.
  - `$B pull-to-refresh <list id>` fires a list's refresh control. `swipe` is a fling and doesn't trigger it.
  - `$B dismiss-save-password [--timeout <s>]` closes iOS's Save Password sheet. It appears when a sign-in screen with typed credentials goes away, and it swallows the next tap.
- `$B snapshot` returns the identified elements with label, value, enabled, visible and rect. Use `--all` to include unidentified ones. Read state from it after acting. Hidden views are not in the tree.
- A missing id fails with the closest real identifiers. Don't fall back to coordinates or labels: add the identifier to the view instead.
- Wait on observable state with `wait`, never fixed sleeps.

## Evidence

`$B screenshot <name>` and `$B record start <name>` / `$B record stop` write to `.verify/evidence/<date>/` (gitignored). Proof standards:

- Drive the production user path through the UI. Don't call internals.
- Capture the trigger and the resulting state, ideally in one recording.
- Check side effects, not just pixels: identifier state from `snapshot`, and stored or server data when the feature writes.
- Exercise every entry point and the success, cancel, error, empty and persistence paths the change can affect, as listed in the feature file.

## Cleanup

`$B cleanup` stops the recording, ends the session, and stops Appium, if this CLI started them. It never kills what it didn't start, and never deletes evidence. Use `--dry-run` to see the plan. Confirm the evidence files still exist afterwards.

## Then make it permanent

Every flow you verify gets an XCUITest: `__PROJECTNAMEIDENTIFIER__UITests/` for the app, a catalog UI test target if you add one. Both run in `bundle exec fastlane test_project`. Use the same identifiers and launch arguments.

## Extending the CLI

`harness/lib/commands.mjs` registers one block per command; `harness/test/` holds its tests (`npm test` in `harness/`). When the app gains a server, add `backend start|stop|reset|seed` commands there, and a `login --as <role>` that drives the real sign-in screen and then calls `dismissSavePasswordPrompt`. Every command prints one JSON object and failures carry a `fix`.

## Feature map

[`features/README.md`](features/README.md) indexes every user-facing feature in sweep order. Open only the file for the feature you changed. Each file has the same four sections: `Sub-features`, `How to get to it (user POV)`, `Driving it with app-ctl`, `Gotchas`. **Every new or changed feature updates its file in the same change.** Run `/maintain-verification-skill` regularly (daily on an active project) to audit the map and the harness against the code and the running app.
