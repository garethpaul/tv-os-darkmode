# Changes

## 2026-06-13

- Prevented initial or unchanged trait callbacks from repeating the appearance
  update and VoiceOver announcement, with executable transition-decision tests.

## 2026-06-12

- Added a tvOS XCTest target and shared scheme covering light, dark, and
  fallback appearance presentation mapping.
- Changed the hosted macOS gate from compile-only verification to executable
  XCTest on the pinned tvOS 18.5 simulator.
- Extended portable contracts across the source, test target, scheme,
  Makefile, workflow, tests, and completed plan.
- Replaced ambiguous default-setup Swift CodeQL autobuild with a pinned
  advanced workflow that manually builds the unsigned tvOS app target while
  preserving actions and Python analysis.
- Calibrated the instrumented Swift CodeQL job to a 25-minute bound after the
  hosted app-target build succeeded in 14m22s but left no analysis headroom.

## 2026-06-10

- Announced trait-driven appearance changes through VoiceOver after updating
  the visible and accessibility label state.
- Migrated the project from Swift 3 and tvOS 10 to Swift 5 and tvOS 12.
- Replaced legacy application entry-point, launch-options, and accessibility
  APIs with current Swift/UIKit syntax and removed empty lifecycle callbacks.
- Added a fixed macOS 15/Xcode 16.4 hosted build alongside the portable static
  contract job, with fixed runners, scoped concurrency, and disabled checkout
  credential persistence.
- Made Make targets independent of the caller's working directory and extended
  mutation-resistant contracts for the toolchain and hosted build.
- Added a least-privilege GitHub Actions workflow that runs the static
  `make check` baseline with commit-pinned Node 24 actions and a bounded
  runtime.
- Added a tvOS static contract guard requiring the CI workflow and completed CI
  baseline plan to remain checked in.

## 2026-06-09

- Updated the app delegate launch callback to the Swift 3 launch-options
  signature and added static contract coverage.
- Marked the appearance label as explicitly non-interactive so it remains a
  display-only status view.
- Extended static tvOS contracts to preserve the display-only label setting.
- Added a stable accessibility identifier to the root appearance view for
  future simulator/UI verification.
- Extended static tvOS contracts to preserve the root view identifier.
- Added an accessibility hint to the appearance label and extended static tvOS
  contracts to preserve it.
- Bounded the appearance label height as well as width inside the tvOS
  viewport.
- Extended static tvOS contracts to preserve the label layout bounds.
- Marked the appearance label with the static-text accessibility trait.
- Extended static tvOS contracts to preserve the accessibility trait guard.
- Enabled appearance-label font scaling for longer runtime states.
- Extended static tvOS contracts to require the scaling guard.

## 2026-06-08

- Added static contrast coverage for light, dark, and fallback appearance
  states.
- Ignored Python bytecode caches produced by local checker syntax validation.
- Added a README manual appearance verification checklist and static coverage
  to keep light/dark behavior checks discoverable.
- Made the appearance-state label wrap and expose stable accessibility text.
- Extended the tvOS static contract check to cover label wrapping and
  accessibility metadata.
- Added `make check` as the shared repository verification alias.
- Added a `make verify` quality gate for tvOS project, plist, asset, and appearance-state contracts.
- Updated the sample to show the current interface style on screen instead of relying only on console output.
- Documented the verification flow and updated project vision notes.
- Added canonical `docs/plans` coverage and made static checks require
  completed plans.
