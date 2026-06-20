# Controller Trait Transition Rendering

## Status: Completed

## Context

Hosted XCTest covers the pure appearance resolver and the controller's initial
dark and light hierarchy. It does not directly prove that an already-loaded
controller updates its visible and accessible state when tvOS changes the
effective interface style.

## Priority

Add mutation-sensitive controller tests for both dark-to-light and
light-to-dark transitions before extending the sample further. This keeps the
sample's central trait-change behavior executable instead of relying only on
source contracts and manual simulator checks.

## Requirements

- R1. Load the real `ViewController` under a known initial interface style.
- R2. Change the child controller's effective trait collection after loading.
- R3. Verify the label text, accessibility label, foreground color, and root
  background color after a dark-to-light transition.
- R4. Verify the same visible and accessible state after a light-to-dark
  transition.
- R5. Extend the static checker so removal of either executable transition
  scenario fails `make check` on non-macOS hosts.
- R6. Preserve production appearance mapping and announcement behavior.

## Implementation Units

### Executable controller transitions

**Files:** `tvos-darkmodeTests/AppearancePresentationTests.swift`

Reuse the existing controller containment and label lookup pattern. Add
bidirectional scenarios that load the controller under one style, apply the
other style through the parent override, deliver the prior trait collection,
and assert the final presentation hierarchy.

### Portable test contracts and maintenance record

**Files:** `scripts/check_tvos_contracts.py`, `README.md`, `VISION.md`,
`CHANGES.md`, `docs/plans/2026-06-13-controller-trait-transition-rendering.md`

Require both transition test names and their before/after style pairings in the
portable contract gate. Document the executable transition coverage and record
the completed validation evidence.

## Verification Plan

- portable static contracts through `make check`
- hosted tvOS XCTest for both controller transition directions
- focused hostile mutations for missing transition tests, reversed styles,
  weakened hierarchy assertions, documentation drift, and stale plan status
- project/XML/plist/asset parsing, intended-path, generated-artifact,
  whitespace, and secret-pattern audits

## Scope Boundaries

- Do not change production rendering, appearance colors, accessibility copy,
  or announcement policy.
- Do not raise the tvOS deployment target or replace
  `traitCollectionDidChange` in this change.
- Do not add UI-test infrastructure, screenshots, network behavior, or third-
  party dependencies.

## Work Completed

- Added dark-to-light and light-to-dark tests around the real loaded controller
  hierarchy.
- Reused one hierarchy assertion for effective style, visible text,
  accessibility text, foreground color, and root background color.
- Extended the portable checker and maintenance docs to preserve both
  transition directions and their initial/final style pairings.

## Verification

- `make check` passed the project, plist, asset, workflow, plan, source, and
  executable-test contracts under a 60-second hard timeout. On this Linux host,
  the Makefile truthfully reported that tvOS XCTest and build execution were
  skipped because `xcodebuild` is unavailable.
- Focused hostile mutations for either missing transition test, reversed style
  pairings, removed final hierarchy assertions, documentation drift, and stale
  plan status were rejected from a passing portable baseline.
- `git diff --check`, intended-path, generated-artifact, structured-file, and
  changed-line secret-pattern audits passed before shipment.
- Exact-head hosted tvOS XCTest remains required on the pull request because it
  is the executable macOS validation environment for this repository.
