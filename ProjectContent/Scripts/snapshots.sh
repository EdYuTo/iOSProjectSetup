#!/bin/bash
# Usage: Scripts/snapshots.sh record|verify <Scheme> <TestTarget/TestClass>
# record: re-renders every snapshot in the class (always exits non-zero, by design)
# verify: compares against the committed references
set -u
mode="$1"; scheme="$2"; only="$3"
cd "$(dirname "$0")/.." || exit 1

if [ "$mode" = "record" ]; then
  export TEST_RUNNER_SNAPSHOT_RECORD=1
fi

xcodebuild test -workspace __PROJECTNAMEIDENTIFIER__.xcworkspace -scheme "$scheme" \
  -destination 'platform=iOS Simulator,name=iPhone 17' -derivedDataPath ./build_data \
  -only-testing:"$only" 2>&1 \
  | grep -E "Image saved to|error:|Executed [0-9]+ tests?|TEST (SUCCEEDED|FAILED)" | sort -u
exit "${PIPESTATUS[0]}"
