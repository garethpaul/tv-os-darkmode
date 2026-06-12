# Changes

## 2026-06-10

- Added a GitHub Actions check workflow that runs the existing static
  `make check` baseline on pushes, pull requests, and manual dispatches.
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
