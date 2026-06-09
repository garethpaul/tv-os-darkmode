# Appearance Label Accessibility Hint

## Status: Completed

## Context

The sample exposes the current light/dark appearance state through a visible
UILabel and already marks it as static text for assistive technologies. A short
accessibility hint makes the label's purpose clearer without adding visible UI.

## Objectives

- Preserve the minimal appearance-state UI.
- Keep the label text and accessibility label synchronized.
- Add a stable accessibility hint that explains the label's purpose.
- Extend static checks so the hint is not removed.

## Work Completed

- Set `appearanceLabel.accessibilityHint` during label configuration.
- Extended `scripts/check_tvos_contracts.py` to require the hint.
- Updated README, VISION, and CHANGES with the accessibility-hint guard.

## Verification

- Negative check before implementation:
  `python3 scripts/check_tvos_contracts.py` failed with
  `appearance label must describe its appearance-state purpose to assistive technologies`.
- `python3 scripts/check_tvos_contracts.py`
- `make check`
- `make verify`
- `git diff --check`

## Xcode Notes

`xcodebuild` was not available in this environment, so tvOS simulator
compilation was not run here. The repository `make check` wrapper still runs
the simulator build when `xcodebuild` is available locally.
