# tvOS Dark Mode CI Baseline

## Status: Completed

## Context

`tv-os-darkmode` has Python-backed static tvOS project, plist, asset, and
appearance contracts behind `make check`, with Xcode builds guarded for hosts
that provide `xcodebuild`. The repository needs those checks in GitHub Actions
before review.

## Objectives

- Run the existing `make check` wrapper in GitHub Actions.
- Keep the hosted job independent of Xcode and tvOS simulator availability.
- Make the workflow presence part of the static baseline contract.

## Work Completed

- Added `.github/workflows/check.yml` to run `make check` on pushes, pull
  requests, and manual dispatches.
- Set up Python 3.12 for the static checker.
- Extended `scripts/check_tvos_contracts.py` to require the CI workflow and
  this completed plan.
- Updated README, VISION, SECURITY, and CHANGES with the CI baseline.

## Verification

- `make check`
- `python3 scripts/check_tvos_contracts.py`
- `git diff --check`

## Follow-Up Candidates

- Add a macOS/tvOS simulator build job once the supported Xcode and simulator
  baseline are documented.
