# __PROJECTNAMEIDENTIFIER__ feature map

Behavior-level inventory of what a user can do in __PROJECTNAMEIDENTIFIER__ and the DesignSystem catalog. Agents use it to decide what to drive and what evidence counts; humans use it as the regression checklist. `$B` is `.claude/skills/verify-app/bin/app-ctl` (see `../SKILL.md`).

One small file per feature, so an agent reads only the index and the file it needs. **Every new or changed feature updates its file in the same change**, verified live. Copy an existing file for a new feature; keep the four sections.

## Baseline preconditions

- Fresh build: `doctor` shows no `STALE` for the app you drive.
- The simulator is `test_device` from `.actions.yml`.
- Identifiers only (`<screen>.<element>[.<qualifier>]`). If an element lacks one, that's a bug: add it.

## Proof and skip reporting

The feature file defines the coverage set. Exercise every reachable entry point and the success, cancel, error, empty and persistence paths the change can affect. Record the action and the final state. When a path is unreachable, name the blocker (planned feature, missing server, simulator limitation) and cover the closest real path.

## Full sweep (top to bottom)

### __PROJECTNAMEIDENTIFIER__ (`--app app`)

- [home](home.md): the first screen, a globe and a greeting.

### DesignSystem catalog (`--app catalog`)

- [catalog](catalog.md): the list of token and component pages, and its empty state.
