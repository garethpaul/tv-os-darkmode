# Changes

## 2026-06-26 06:20 PDT - P2 - Validate the simctl JSON root

### Summary

Rejected non-object `simctl list --json` roots before simulator runtime/device
access so valid JSON schema drift cannot escape as a raw attribute traceback.
Non-object `simctl list --json` roots fail before runtime or device access.

### Work completed

- Added table-driven regressions for JSON `null`, array, string, number, and
  boolean roots.
- Added one root-shape guard before the first payload access.
- Added mutation-sensitive source ordering, fixture, guidance, and plan
  contracts.
- Synchronized contributor, public, security, and product guidance.

### Threads

- None; Swift lifecycle, simulator selection, Xcode workflows, plans, issues,
  PRs, and recent hosted evidence were reviewed directly.

### Files changed

- `scripts/select_tvos_destination.py` — stable non-object root failure.
- `tests/test_select_tvos_destination.py` — malformed-root regressions.
- `scripts/check_tvos_contracts.py` — durable ordering and fixture contracts.
- `AGENTS.md`, `README.md`, `SECURITY.md`, and `VISION.md` — maintained
  behavior contract.
- `docs/plans/2026-06-26-simctl-root-shape.md` — implementation record.

### Validation

- RED focused selector test — five malformed roots escaped as `AttributeError`.
- GREEN focused selector test — all five now raise the stable `RuntimeError`.
- `./scripts/run-make.sh check` — passed Make authority checks, eight static
  contract groups, and all seven portable selector tests.
- Seven isolated hostile source, ordering, regression, fixture, guidance, and
  plan mutations — all rejected.
- tvOS XCTest and simulator compilation — skipped because Xcode is unavailable
  on Linux; hosted Xcode 16.4 remains required.

### Bugs / findings

- P2 reliability: valid JSON with a non-object root bypassed the selector's
  controlled error path and could print a Python traceback in CI.

### Blockers

- Local Linux cannot run tvOS XCTest; hosted Xcode 16.4 remains required.

### Next action

- Complete exact-head review, hosted Xcode/CodeQL, and merge.

## 2026-06-25 - P1 - Validate tvOS simulator identifiers

### Summary

Prevented the hosted XCTest destination selector from emitting blank simulator
identifiers and deferring the failure into `xcodebuild`.

### Work completed

- Added shared normalization for discovered and newly created simulator UDIDs.
- Skipped matching devices whose identifier is missing, non-string, or blank.
- Rejected empty `simctl create` output with a stable selector error.
- Added portable regression tests and mutation-sensitive static contracts.

### Validation

- Both focused blank-ID selector tests failed before implementation; the final
  matrix also covers non-string discovered and created identifiers.
- `make check` covers the selector suite and repository static contracts; real
  simulator creation remains a hosted macOS gate.
- A hostile normalization mutation that restored blank identifier acceptance
  was rejected by both focused regressions.

### Bugs / findings

- P1: malformed simulator metadata could produce
  `platform=tvOS Simulator,id=` and obscure the root cause in `xcodebuild`.

## 2026-06-24 23:37 PDT - P2 - Preserve raw MAKEFILES reproduction

### Summary

Exported the hostile `MAKEFILES` fixture before the authority helper invokes
raw Make so the startup-file regression behaves consistently across POSIX
shells.

### Work completed

- Wrapped the raw Make invocation in a subshell with exported `MAKEFILES`.
- Preserved the existing proof that the trusted wrapper clears inherited Make
  startup authority.

### Threads

- None. The focused shell fixture and existing hosted evidence were sufficient.

### Files changed

- `scripts/test-makefile-authority.sh` — exported the startup fixture through
  the helper boundary.
- `CHANGES.md` — recorded this maintenance cycle.

### Validation

- `/bin/sh scripts/test-makefile-authority.sh` — passed.
- `make check` — static contracts and three host tests passed; local Xcode
  build and XCTest skipped because `xcodebuild` is unavailable.
- Hosted `xcode-test`, static contracts, and CodeQL — passed at PR head
  `225e3ff`.
- Codex review — clean with no accepted or actionable findings before this
  documentation-only cycle record.

### Bugs / findings

- Temporary environment assignments are not required to propagate through
  shell functions, so the prior fixture could silently omit `MAKEFILES`.

### Blockers

- None.

### Next action

- Rerun Codex review and hosted checks on the documented head, then merge PR
  #11 if both remain clean.

- Added a fixed `scripts/run-make.sh` entrypoint for hosted `check` and `test`
  runs. It clears inherited Make control variables, rejects options,
  assignments, extra targets, and alternate Makefiles, and invokes the physical
  repository Makefile through fixed system tools. It resolves bounded relative
  and absolute script symlink chains without losing spaces, quotes, or newline
  bytes, and rejects broken or overlong chains. Regression tests reproduce raw
  `--eval`, dry-run, ignore-errors, `GNUMAKEFLAGS`, `MAKEFILES`, and earlier `-f`
  authority before proving the wrapper excludes those channels.
- Hardened repository Make rules against Make-syntax interpreter injection,
  caller shell replacement, visible non-executing flags, populated `MAKEFILES`,
  `MAKEFILE_LIST` root substitution, and root redirection while preserving
  literal Python and tvOS destination overrides.

## 2026-06-19

- Added a deterministic appearance transition state that suppresses duplicate,
  hidden, and inactive VoiceOver announcements while preserving immediate
  visual rendering and one announcement when presentation resumes.
- Adopted the tvOS 13 scene lifecycle without removing the tvOS 12 app-delegate
  and storyboard fallback required by the deployment floor.
- Made local XCTest select the named simulator available to the chosen Xcode
  and isolated DerivedData under the ignored repository `.build` directory.
- Made hosted XCTest create the matching Apple TV simulator when a runner has
  an installed tvOS runtime but no pre-created device.
- Added main-actor UI ownership and five state tests covering initial,
  repeated, hidden, inactive, and round-trip appearance transitions.

## 2026-06-16

- Added focused tvOS 17 trait registration while preserving the tvOS 12 through
  16 `traitCollectionDidChange` fallback through one transition handler.

## 2026-06-13

- Added hosted controller-level coverage for dark-to-light and light-to-dark
  trait transitions, including visible and accessible appearance state.
- Added controller-level tvOS XCTest for dark and light rendered hierarchy,
  colors, text, and accessibility identifiers without exposing private state.
- Prevented initial or unchanged trait callbacks from repeating the appearance
  update and VoiceOver announcement, with executable transition-decision tests.

## 2026-06-12

- Added a tvOS XCTest target and shared scheme covering light, dark, and
  fallback appearance presentation mapping.
- Changed the hosted macOS gate from compile-only verification to executable
  XCTest on the pinned tvOS 18.5 simulator.
- Extended portable contracts across the source, test target, scheme,
  Makefile, workflow, tests, and completed plan.
- Replaced ambiguous default-setup Swift CodeQL autobuild with a pinned
  advanced workflow that manually builds the unsigned tvOS app target while
  preserving actions and Python analysis.
- Calibrated the instrumented Swift CodeQL job to a 25-minute bound after the
  hosted app-target build succeeded in 14m22s but left no analysis headroom.

## 2026-06-10

- Announced trait-driven appearance changes through VoiceOver after updating
  the visible and accessibility label state.
- Migrated the project from Swift 3 and tvOS 10 to Swift 5 and tvOS 12.
- Replaced legacy application entry-point, launch-options, and accessibility
  APIs with current Swift/UIKit syntax and removed empty lifecycle callbacks.
- Added a fixed macOS 15/Xcode 16.4 hosted build alongside the portable static
  contract job, with fixed runners, scoped concurrency, and disabled checkout
  credential persistence.
- Made Make targets independent of the caller's working directory and extended
  mutation-resistant contracts for the toolchain and hosted build.
- Added a least-privilege GitHub Actions workflow that runs the static
  `make check` baseline with commit-pinned Node 24 actions and a bounded
  runtime.
- Added a tvOS static contract guard requiring the CI workflow and completed CI
  baseline plan to remain checked in.

## 2026-06-09

- Updated the app delegate launch callback to the Swift 3 launch-options
  signature and added static contract coverage.
- Marked the appearance label as explicitly non-interactive so it remains a
  display-only status view.
- Extended static tvOS contracts to preserve the display-only label setting.
- Added a stable accessibility identifier to the root appearance view for
  future simulator/UI verification.
- Extended static tvOS contracts to preserve the root view identifier.
- Added an accessibility hint to the appearance label and extended static tvOS
  contracts to preserve it.
- Bounded the appearance label height as well as width inside the tvOS
  viewport.
- Extended static tvOS contracts to preserve the label layout bounds.
- Marked the appearance label with the static-text accessibility trait.
- Extended static tvOS contracts to preserve the accessibility trait guard.
- Enabled appearance-label font scaling for longer runtime states.
- Extended static tvOS contracts to require the scaling guard.

## 2026-06-08

- Added static contrast coverage for light, dark, and fallback appearance
  states.
- Ignored Python bytecode caches produced by local checker syntax validation.
- Added a README manual appearance verification checklist and static coverage
  to keep light/dark behavior checks discoverable.
- Made the appearance-state label wrap and expose stable accessibility text.
- Extended the tvOS static contract check to cover label wrapping and
  accessibility metadata.
- Added `make check` as the shared repository verification alias.
- Added a `make verify` quality gate for tvOS project, plist, asset, and appearance-state contracts.
- Updated the sample to show the current interface style on screen instead of relying only on console output.
- Documented the verification flow and updated project vision notes.
- Added canonical `docs/plans` coverage and made static checks require
  completed plans.
