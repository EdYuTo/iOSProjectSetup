# ADR 0001: Live verification with app-ctl and a Feature Map

- **Status:** Accepted
- **Context:** Agents change UI code faster than a person can check it, and unit tests don't show whether a screen actually works. An agent needs a reliable way to run the app, act like a user, and capture proof, plus a compact description of what the app does so it doesn't re-read the whole codebase for every task.
- **Decision:**
  - A project skill, `verify-app`, with an agent-friendly CLI, `app-ctl`, built on Appium + the XCUITest driver + WebdriverIO. Its Node dependencies are pinned and local to the skill (`harness/package-lock.json`); nothing is installed globally. Every command prints one JSON object, and failures carry a `fix`.
  - Elements are found only by accessibility identifier (`<screen>.<element>[.<qualifier>]`), the same identifiers the XCUITests use.
  - A **Feature Map** inside the skill (`features/`): an index plus one small file per feature, each with the same four sections (sub-features, how to reach it as a user, how to drive it, gotchas). An agent reads the index and only the file it needs, so the cost stays flat as the app grows.
  - Appium is only for live exploration and proof. Every flow verified live becomes a native XCUITest, so the committed regression suite stays Swift-only.
  - `/maintain-verification-skill` (vendored from Lauren's [pstack](https://x.com/poteto)) audits the map and the harness periodically: one source reader per feature, a live pass over every feature, and a single change of proven corrections.
- **Consequences:**
  - Agents can prove a change in a few commands once WebDriverAgent is built (about 3 minutes, once per machine).
  - Node 22+ is needed to explore, not to build or test.
  - Two automation stacks to understand (Appium for exploration, XCUITest for regression), sharing one identifier convention.
  - The map rots unless maintained: each feature updates its file in the same change, and the maintenance pass catches what slips.
- **Alternatives considered:** committing Appium suites as tests (a second test toolchain in CI); a custom XCUITest-based remote control (reimplements WebDriverAgent); an Appium MCP server (duplicates the CLI and is harder to script or reproduce).
