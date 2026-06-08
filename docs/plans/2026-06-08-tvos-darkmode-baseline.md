# tvOS Dark Mode Baseline

## Status: Completed

## Context

`tv-os-darkmode` is a minimal tvOS sample that observes trait collection changes
and displays the current light/dark appearance state. The maintenance baseline
should keep the sample focused, inspectable, and accessible without requiring
Xcode on every machine.

## Objectives

- Preserve the trait-collection appearance detection example.
- Keep visible appearance state in sync with trait changes.
- Ensure the appearance label wraps and exposes stable accessibility metadata.
- Run plist, asset, project, appearance, and docs-plan checks through
  `make check`.
- Maintain completed maintenance plans under `docs/plans`.

## Work Completed

- Confirmed `make check` runs tvOS static contract checks and optional Xcode
  build execution.
- Added canonical `docs/plans` coverage for the current appearance baseline.
- Extended static checks to require completed `docs/plans` entries with
  `make check` verification.
- Updated README, VISION, and CHANGES to make the baseline discoverable.

## Verification

- `python3 scripts/check_tvos_contracts.py`
- `make check`
- `make verify`
- `git diff --check`

## Follow-Up Candidates

- Add device or simulator screenshots for light and dark appearances.
- Document supported tvOS and Xcode versions.
