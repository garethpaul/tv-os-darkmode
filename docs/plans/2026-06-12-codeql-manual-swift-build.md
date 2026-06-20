# CodeQL Manual Swift Build

Status: Completed

## Problem

GitHub CodeQL default setup analyzes actions and Python quickly, but its Swift
autobuild remains stuck after the repository's explicit Xcode test job has
already built the app and passed all three tests. Default setup chooses the
largest Xcode target automatically, which is ambiguous now that the project
contains an app and a hosted unit-test bundle.

## Plan

1. Add an advanced CodeQL workflow with immutable action pins, least-privilege
   permissions, bounded jobs, and canonical push, pull-request, schedule, and
   manual triggers.
2. Keep actions and Python analysis on Ubuntu with no build.
3. Analyze Swift on macOS with a manual, unsigned, single-architecture
   `xcodebuild -target tvos-darkmode` invocation rather than the shared scheme,
   whose BuildAction also includes the separately tested XCTest bundle.
   Bound the instrumented Swift job at 25 minutes so the observed 14-minute
   target build leaves time for CodeQL database finalization and analysis.
4. Extend the portable baseline checker to reject workflow removal, mutable
   actions, permission drift, autobuild, or loss of the explicit tvOS build.
5. Disable repository default setup only when the advanced workflow is ready
   to push, then require the exact-head functional and CodeQL workflows to pass.

## Verification

- Ruby parsed both workflow files, and the portable baseline contracts passed
  locally before hosted setup replacement.
- `make check` passed all eight static groups; XCTest and unsigned build
  reported explicit Linux-host skips because Xcode is unavailable locally.
- An external-working-directory Make invocation passed the same gate.
- Four isolated mutations rejected Swift autobuild, a mutable CodeQL action,
  loss of the single-architecture bound, and reduced upload permissions.
- Functional run `27423765496` passed at `bc8455ad2c4243b14a48a388c369dff9ffc9b70b`.
- CodeQL run `27423765176` proved the single app target builds successfully
  under Swift instrumentation, but its 14m22s build exhausted the original
  15-minute job bound before analysis; the bound was recalibrated to 25 minutes
  without changing the analyzed target, architecture, or source coverage.
- At exact head `3ce7b07f71fe236165405749e8cc1c2ecb1dcda2`, functional
  run `27424962418` passed and CodeQL run `27424962453` passed actions,
  Python, and Swift analysis. The Swift job completed in 15m46s, including a
  successful 13m43s instrumented app-target build, within the calibrated
  25-minute bound.
- `python3 -m py_compile scripts/check_tvos_contracts.py` and
  `git diff --check` passed.
