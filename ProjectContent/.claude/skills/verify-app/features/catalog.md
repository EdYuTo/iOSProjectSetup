# Catalog

The DesignSystem catalog app: a list of token and component pages (`CatalogEntry.all`), each opening a page that shows it in its states.

## Sub-features

- **empty-state:** with no entries, `catalog.empty` contains "No components yet" and a hint to add entries to `CatalogEntry.all`.
- **entry-list:** `catalog.list`, one row per entry: `catalog.entry.<id>`. Tapping a row pushes its page.

## How to get to it (user POV)

Open Catalog (the `DesignSystemCatalog` app). The list is the first screen; tap a row to open its page, Back to return.

## Driving it with app-ctl

```bash
$B build --app catalog && $B launch --app catalog
$B snapshot                        # catalog.empty until entries exist, then catalog.list and catalog.entry.<id>
$B tap catalog.entry.<id>          # once entries exist
$B back
```

- Give each page's root an identifier (`<entryId>.page`) so `wait` can confirm it opened.

## Gotchas

- Rows below the fold need `swipe catalog.list up` before `tap`.
- An identifier on a SwiftUI container needs `.accessibilityElement(children: .contain)`, or SwiftUI copies it onto every child (see [home](home.md)).
- The catalog starts empty in a new project: adding the first token or component to DesignSystem should add its entry, and this file's sub-features.
