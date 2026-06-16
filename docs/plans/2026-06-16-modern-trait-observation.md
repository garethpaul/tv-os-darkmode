# Modern Trait Observation

## Status: Completed

## Context

`ViewController` still observes appearance changes exclusively through
`traitCollectionDidChange(_:)`. UIKit deprecated that callback in tvOS 17 and
recommends registering only the traits an object needs. The sample still
supports tvOS 12, so removing the callback outright would break the deployment
floor.

## Priority

P1 compatibility and maintainability. Use current UIKit trait observation on
tvOS 17 and later without duplicating appearance updates or accessibility
announcements, while preserving the existing tvOS 12 through 16 fallback.

## Requirements

- Register specifically for `UITraitUserInterfaceStyle` changes on tvOS 17+.
- Route modern registration and the legacy callback through one transition
  handler.
- Keep `traitCollectionDidChange(_:)` active only below tvOS 17.
- Preserve initial rendering, bidirectional appearance updates, and the rule
  that missing or unchanged prior styles do not announce.
- Add portable static contracts and hosted XCTest coverage for the modern and
  fallback structure without raising the tvOS deployment target.

## Approach

Register during `viewDidLoad()` after the initial appearance is rendered. The
registration handler receives the previous trait collection and delegates to a
shared appearance-transition method. The legacy override returns immediately
on tvOS 17+, preventing duplicate updates and announcements when the modern
registration is active.

## Verification

- Run portable contracts from the repository and through the absolute Makefile
  path from an external directory.
- Require hosted tvOS XCTest to compile and execute the availability-gated
  modern API and legacy fallback.
- Reject mutations that remove registration, broaden the observed traits,
  remove the availability guard, bypass the shared handler, duplicate update
  logic, weaken tests, or leave this plan incomplete.
- Audit exact paths, generated artifacts, secrets, conflict markers, binaries,
  large files, and whitespace.

## Scope Boundaries

- Do not raise the tvOS 12 deployment target.
- Do not alter appearance colors, labels, accessibility copy, constraints,
  storyboard structure, project signing, workflow shape, or dependencies.
- Simulator screenshots and physical VoiceOver evidence remain separate macOS
  or device validation.

## Success Criteria

- tvOS 17+ observes only user-interface-style changes through
  `registerForTraitChanges`.
- tvOS 12 through 16 retain the legacy callback.
- Every real style transition updates once and announces once.
- Portable and hosted gates preserve both paths.

## Verification Completed

- Portable `make check` passed from the repository and through the absolute
  Makefile path from an external directory; Linux truthfully skipped native
  tvOS build and XCTest because `xcodebuild` is unavailable.
- Eight hostile modern trait observation mutations were rejected across the
  focused registration, availability guards, shared routing, guidance, and
  completed plan.
- Exact diff, generated-artifact, secret, conflict-marker, binary, large-file,
  and whitespace audits passed for the intended paths.
- Native Xcode 16.4 compilation and tvOS 18.5 XCTest remain required from the
  pull request's bounded hosted snapshot before this stack is merge-ready.
