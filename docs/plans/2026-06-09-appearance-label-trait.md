# Appearance Label Trait

## Status: Completed

## Context

The tvOS sample exposes the visible appearance-state label as an accessibility
element with stable text and identifier. It did not explicitly mark the label as
static text, leaving assistive technologies with less context about the element
role.

## Objectives

- Preserve the existing visible appearance-state label behavior.
- Mark the label with the static-text accessibility trait.
- Extend static contracts so the trait remains part of the accessibility
  baseline.

## Work Completed

- Added `UIAccessibilityTraitStaticText` to the appearance label configuration.
- Extended `scripts/check_tvos_contracts.py` to require the static-text trait.
- Updated README, VISION, and CHANGES with the new accessibility guard.

## Verification

- `python3 scripts/check_tvos_contracts.py`
- `make lint`
- `make test`
- `make build`
- `make check`
- `make verify`
- `git diff --check`

## Follow-Up Candidates

- Add simulator-backed VoiceOver verification when Xcode is available.
- Capture light and dark screenshots for the manual verification checklist.
