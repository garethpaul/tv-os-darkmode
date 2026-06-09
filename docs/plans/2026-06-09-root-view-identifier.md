# Root View Identifier

## Status: Completed

## Context

The appearance label already exposes a stable accessibility identifier, but the
root view carrying the light/dark background did not. Future simulator or UI
automation should be able to find both the text label and the background view
without relying on view hierarchy position.

## Objectives

- Add a stable accessibility identifier to the root appearance view.
- Keep the identifier aligned with the existing appearance-state naming.
- Extend static checks so the identifier remains in place.
- Document the automation hook under `docs/plans`.

## Work Completed

- Set `view.accessibilityIdentifier` during `viewDidLoad`.
- Extended `scripts/check_tvos_contracts.py` to require the root view
  identifier and completed plan.
- Updated README, VISION, and CHANGES.

## Verification

- `python3 scripts/check_tvos_contracts.py`
- `make check`
- `git diff --check`

`xcodebuild` is not available in this environment, so simulator build
verification was skipped after static checks passed.

## Follow-Up Candidates

- Add simulator screenshots for light and dark appearances.
- Add UI tests that assert the root view background and label text by
  accessibility identifier.
