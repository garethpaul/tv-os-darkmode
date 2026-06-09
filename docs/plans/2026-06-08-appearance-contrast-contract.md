# Appearance Contrast Contract

## Status: Completed

## Context

The tvOS sample sets different foreground and background colors for dark,
light, and fallback appearance states. Static checks already protected visible
text and accessibility metadata, but did not require the text color update or
the expected foreground/background pairings.

## Objectives

- Preserve the minimal light/dark appearance sample.
- Require readable foreground/background pairings for each appearance state.
- Ensure `setAppearance` applies text color as part of every update.
- Keep README, VISION, and CHANGES aligned with the new guard.

## Work Completed

- Extended `scripts/check_tvos_contracts.py` to require white-on-black dark
  mode, black-on-white light mode, and white-on-dark-gray fallback mode.
- Tightened the `setAppearance` contract so text color must update alongside
  text, accessibility text, and background color.
- Updated repository maintenance documentation.

## Verification

- `python3 scripts/check_tvos_contracts.py`
- `make check`
- `make verify`
- `git diff --check`

## Follow-Up Candidates

- Add simulator screenshots for Light and Dark appearance.
- Add simulator-backed verification when `xcodebuild` is available.
