# tvOS Static Contract Gate

## Status: Completed

## Context

`tv-os-darkmode` has deterministic Python-backed contracts for its Xcode
project, plist, storyboard, asset catalogs, appearance behavior, accessibility,
and completed plans. Full compilation and runtime verification require macOS,
Xcode, and a tvOS simulator or device, but the portable contracts previously
had no hosted gate.

## Objectives

- Run all portable contracts on pushes and pull requests.
- Keep the workflow least-privilege, immutable, and bounded.
- Preserve a manual maintenance trigger.
- Avoid implying that Linux validates the tvOS build or runtime.

## Work Completed

- Added `.github/workflows/check.yml` for pushes to `master`, pull requests,
  and manual runs.
- Granted only read access to repository contents, disabled checkout credential
  persistence, and set a five-minute timeout.
- Pinned checkout and Python setup actions to immutable Node 24 commits.
- Ran the existing `make check` entry point with Python 3.12.
- Extended `scripts/check_tvos_contracts.py` to enforce workflow triggers,
  permissions, timeout, action pins, runtime, and command.
- Updated README, SECURITY, VISION, and CHANGES with the hosted baseline.

## Verification

- `python3 -m py_compile scripts/check_tvos_contracts.py`
- `python3 scripts/check_tvos_contracts.py`
- `make check`
- `git diff --check`

The Linux job validates portable repository and source contracts only. It does
not compile Swift, run XCTest, launch a tvOS simulator, validate signing, or
visually inspect light and dark appearances.
