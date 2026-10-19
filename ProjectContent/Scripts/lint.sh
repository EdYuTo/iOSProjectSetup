#!/bin/bash
# Runs SwiftLint through mise so the version pinned in .mise.toml is used.
# Xcode build phases start with a minimal PATH, so add the usual mise locations.
export PATH="$HOME/.local/bin:/opt/homebrew/bin:/usr/local/bin:$PATH"

cd "$(dirname "$0")/.." || exit 1

if command -v mise >/dev/null 2>&1; then
  mise exec -- swiftlint lint --quiet
else
  echo "warning: mise not found, skipping SwiftLint"
fi
