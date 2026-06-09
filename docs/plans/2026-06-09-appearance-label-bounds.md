# Appearance Label Bounds

## Status: Completed

## Context

The tvOS sample centers a dynamic appearance-state label and already protects
wrapping, scaling, contrast, and accessibility metadata. The label had an
explicit width bound, but no matching height bound or static contract ensuring
the bounds remain in place for longer fallback strings.

## Objectives

- Preserve the minimal light/dark appearance sample.
- Keep the appearance label bounded within the tvOS viewport.
- Add a vertical layout bound to complement the existing width bound.
- Extend static contracts so label bounds remain intentional.

## Work Completed

- Added a height constraint limiting the appearance label to 80 percent of the
  view height.
- Extended `scripts/check_tvos_contracts.py` to require both width and height
  label bounds.
- Updated README, VISION, and CHANGES with the bounded-layout guard.

## Verification

- `python3 scripts/check_tvos_contracts.py`
- `make lint`
- `make test`
- `make build`
- `make check`
- `make verify`
- `git diff --check`

## Verification Notes

- XcodeBuildMCP simulator verification was unavailable in this session.
- `xcodebuild` was unavailable on this host, so `make build` used the
  documented skip path.

## Follow-Up Candidates

- Add simulator screenshots for light and dark appearances when Xcode is
  available.
- Add an automated simulator UI check for label visibility and contrast when
  tvOS simulator tooling is available.
