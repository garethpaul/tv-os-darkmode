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
- Exact-head GitHub Actions functional and CodeQL runs
- `python3 -m py_compile scripts/check_tvos_contracts.py` and
  `git diff --check` passed.
