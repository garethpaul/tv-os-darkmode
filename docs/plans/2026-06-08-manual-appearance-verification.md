# Manual Appearance Verification

## Status: Completed

## Context

The static checker preserves plist, project, asset, and appearance-state source
contracts, but the README did not state what a human should confirm when
running the sample on a tvOS simulator or device.

## Objectives

- Preserve the minimal dark/light appearance sample.
- Document manual checks for Light and Dark appearance states.
- Document the fallback state when `userInterfaceStyle` is unavailable.
- Keep the checklist covered by static verification.

## Work Completed

- Added a README manual appearance verification checklist.
- Linked the checklist from Maintenance Notes.
- Extended `scripts/check_tvos_contracts.py` to require the checklist and plan
  reference.
- Updated VISION and CHANGES.

## Verification

- `python3 scripts/check_tvos_contracts.py`
- `make check`
- `make verify`
- `git diff --check`

## Follow-Up Candidates

- Add simulator screenshots for Light and Dark appearance.
- Add simulator-backed verification when `xcodebuild` is available.
