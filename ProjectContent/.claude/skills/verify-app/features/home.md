# Home

The app's first screen: a globe icon and a greeting.

## Sub-features

- **greeting:** `home.greeting` reads "Hello, world!".
- **icon:** `home.globe`, the SF Symbol globe in the accent colour.
- **root:** `home.root` contains both.

## How to get to it (user POV)

Open __PROJECTNAMEIDENTIFIER__. Home is the first screen.

## Driving it with app-ctl

```bash
$B doctor
$B build --app app && $B launch --app app
$B wait home.greeting
$B snapshot                        # home.greeting label "Hello, world!", home.globe present
$B screenshot home
$B cleanup
```

- Pinned by `__PROJECTNAMEIDENTIFIER__UITests.testHomeShowsTheGreeting`.

## Gotchas

- SwiftUI only exposes a container's identifier when it has `.accessibilityElement(children: .contain)`; without it, `home.root` would replace its children's identifiers.
