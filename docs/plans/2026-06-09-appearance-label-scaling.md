# Appearance Label Scaling

## Status: Completed

## Context

The tvOS sample now shows light, dark, fallback, and unavailable appearance
states in a centered label. The label wraps, but the fallback strings should
also have an explicit scaling contract so longer runtime states do not overflow
the visible tvOS viewport.

## Objectives

- Preserve the minimal appearance-state sample.
- Keep the appearance label readable if text needs to fit a narrower viewport.
- Extend static contracts so label scaling remains intentional.

## Work Completed

- Enabled `adjustsFontSizeToFitWidth` on the appearance label.
- Set a readable `minimumScaleFactor` for scaled text.
- Extended `scripts/check_tvos_contracts.py` to require the scaling settings.
- Updated README, VISION, and CHANGES.

## Verification

- `python3 scripts/check_tvos_contracts.py`
- `make check`
- `make verify`
- `git diff --check`

## Follow-Up Candidates

- Add simulator screenshots for light and dark appearances when Xcode is
  available.
- Add an automated simulator UI check for label visibility and contrast when
  tvOS simulator tooling is available.
