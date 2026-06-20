---
title: "test: Exercise tvOS controller appearance rendering"
type: test
date: 2026-06-13
---

# Controller Appearance Rendering Tests

## Status: Completed

## Context

Existing XCTest covers the pure appearance resolver and announcement predicate,
but does not instantiate `ViewController` or prove that `viewDidLoad` wires the
resolved state into the real label, root view, and accessibility identifiers.

## Requirements

- R1. Instantiate `ViewController` under tvOS-compatible parent trait
  overrides for dark and light styles and load its view hierarchy.
- R2. Verify the actual appearance label text, text color, accessibility label,
  and accessibility identifier for both styles.
- R3. Verify the root view background color and accessibility identifier.
- R4. Keep production visibility encapsulated; tests must locate views through
  public UIKit hierarchy and accessibility contracts rather than new test-only
  APIs.
- R5. Preserve resolver, announcement, layout, workflow, project, and signing
  behavior.
- R6. Portable contracts must require both controller tests and their key
  hierarchy assertions; hosted tvOS XCTest remains the executable authority.

## Scope Boundaries

- Do not add a UI-test target, snapshots, app launch automation, or signing.
- Do not alter runtime appearance behavior or expose private controller state.
- Do not claim visual pixel fidelity or VoiceOver device verification.

## Implementation Units

### U1. Add controller-level XCTest

- **Files:** `tvos-darkmodeTests/AppearancePresentationTests.swift`
- Add dark and light tests that apply an override, call `loadViewIfNeeded`, find
  the label by accessibility identifier, and assert rendered UIKit state.

### U2. Preserve portable contracts

- **Files:** `scripts/check_tvos_contracts.py`
- Require both test names, hierarchy lookup, style overrides, view loading,
  rendered colors/text, and accessibility assertions.

### U3. Record the verification boundary

- **Files:** `README.md`, `VISION.md`, `CHANGES.md`
- Distinguish controller rendering coverage from full app-launch, visual, and
  assistive-technology verification.

## Verification

- `make check` on Python 3.12.8 passed all portable contracts with truthful
  XCTest and app-build skips because Xcode is unavailable on this Linux host.
- Hostile mutations removing either style test or hierarchy assertion were
  rejected.
- Python compilation, structured-file parsing, `git diff --check`, and focused
  secret/artifact review passed.
- Hosted macOS 15, Xcode 16.4, tvOS 18.5 XCTest on the exact pushed head remains
  the required executable merge gate.
