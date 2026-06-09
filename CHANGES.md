# Changes

## 2026-06-09

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
