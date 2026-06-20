---
title: "fix: Avoid duplicate initial appearance announcements"
type: fix
date: 2026-06-13
---

# Avoid Duplicate Initial Appearance Announcements

## Status: Completed

## Context

`viewDidLoad` already applies the initial tvOS appearance. The subsequent trait
callback currently treats a missing previous trait collection as a style
change, which can repeat that update and post an unnecessary accessibility
announcement during initial presentation.

## Requirements

- R1. Keep initial appearance rendering in `viewDidLoad`.
- R2. Announce only when a known previous interface style differs from the new
  style.
- R3. Skip announcements for a missing previous style or an unchanged style.
- R4. Cover nil, unchanged, light-to-dark, and dark-to-light decisions with
  executable XCTest cases.
- R5. Preserve existing appearance colors, labels, identifiers, and VoiceOver
  announcement ordering.

## Scope Boundaries

This change adjusts only announcement eligibility. It does not replace
`traitCollectionDidChange`, alter the visual presentation, add UI automation,
or change the minimum tvOS deployment target.

## Implementation Units

### U1. Extract the Announcement Predicate

- **Goal:** Make initial and redundant callback behavior explicit and testable.
- **Files:** `tvos-darkmode/ViewController.swift`
- **Approach:** Add a pure appearance-change predicate that requires a previous
  style and compares it with the current style. Use it as the trait callback's
  guard before updating and announcing.
- **Test scenarios:** Missing previous style returns false; equal styles return
  false; light-to-dark and dark-to-light return true.
- **Verification:** The trait callback still updates before posting the
  accessibility announcement for real changes.

### U2. Add Executable and Static Contracts

- **Goal:** Prevent duplicate initial announcements from returning.
- **Files:** `tvos-darkmodeTests/AppearancePresentationTests.swift`,
  `scripts/check_tvos_contracts.py`
- **Approach:** Add deterministic XCTest cases for the pure predicate and
  require the predicate, nil guard semantics, tests, and ordering statically.
- **Test scenarios:** Mutations that accept nil, accept equal styles, reject a
  real transition, remove a test, or bypass the predicate are rejected.
- **Verification:** Static checks pass locally; hosted tvOS XCTest remains the
  executable authority.

### U3. Record the Accessibility Contract

- **Goal:** Document the completed behavior and actual verification evidence.
- **Files:** `README.md`, `VISION.md`, `CHANGES.md`,
  `docs/plans/2026-06-13-initial-appearance-announcement.md`
- **Approach:** Explain that initial state is rendered once and only real style
  transitions generate announcements.
- **Test expectation:** Documentation is enforced by the completed-plan
  checker; no separate runtime behavior is introduced.
- **Verification:** The completed plan distinguishes local static validation
  from hosted Xcode execution.

## Risks

- A predicate that rejects all transitions would silence useful announcements.
- Moving the accessibility post before the visual update would announce stale
  state.
- Local Linux validation cannot execute UIKit or XCTest.

## Assumptions

- `viewDidLoad` remains the single initial appearance render path.
- The existing macOS 15/Xcode 16.4 hosted job provides tvOS 18.5 XCTest
  execution for the successor PR.

## Work Completed

- Added a pure announcement predicate that requires a known previous style and
  a real style transition.
- Routed `traitCollectionDidChange` through the predicate before updating or
  posting the accessibility announcement.
- Added executable nil, unchanged, light-to-dark, and dark-to-light XCTest
  cases.
- Extended portable contracts for the predicate, callback use, test names, and
  update-before-announcement ordering.
- Updated manual verification, vision, and change documentation.

## Verification

- `make check` on Python 3.12.8 passed all eight portable contract groups
- Local XCTest and app build were truthfully skipped because `xcodebuild` is not
  available on this Linux host
- Five hostile mutations covering nil, equality, transition, callback, and
  executable-test contracts were rejected
- `python -m py_compile scripts/check_tvos_contracts.py`
- `git diff --check`

The successor PR must provide the canonical macOS 15/Xcode 16.4 tvOS 18.5
XCTest result before this change is eligible to merge.
