# Appearance Label Display-Only Guard

## Status: Completed

## Context

The tvOS sample uses one visible label to report the current interface style.
That label should remain a display-only status view: it is exposed to
assistive technologies as static text, but it should not become a
user-interactive control in the focusable UI.

## Objectives

- Keep the appearance label non-interactive.
- Preserve the existing accessibility metadata for static text.
- Extend static tvOS contracts so the display-only setting remains covered by
  `make check`.

## Work Completed

- Set `appearanceLabel.isUserInteractionEnabled = false` during label
  configuration.
- Extended `scripts/check_tvos_contracts.py` to preserve the display-only
  label contract.
- Updated README, VISION, and CHANGES.

## Verification

- Negative check before implementation:
  `make check` failed with
  `appearance label must remain a display-only, non-interactive view`.
- `python3 scripts/check_tvos_contracts.py`
- `make check`
- `git diff --check`

## Follow-Up Candidates

- Add simulator-backed focus verification when Xcode is available.
- Capture light and dark screenshots for the manual verification checklist.
