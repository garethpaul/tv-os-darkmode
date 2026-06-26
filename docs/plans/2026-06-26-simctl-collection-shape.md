# Simctl Collection Shape Implementation Plan

Status: Completed

**Goal:** Fail with stable selector errors when traversed `simctl list --json`
collections are malformed.

**Architecture:** Add narrow collection validators inside the selector module.
Validate the runtime and device-type arrays, the devices object, and the chosen
runtime's device array before iteration. Do not broaden `main` exception
handling or validate unrelated `simctl` fields.

**Tech Stack:** Python 3, `unittest`, Xcode `simctl`, GNU Make, GitHub Actions.

---

### Task 1: Prove Nested Shape Failures

**Files:**
- Modify: `tests/test_select_tvos_destination.py`

1. Add table-driven malformed container and entry regressions.
2. Run the focused test and confirm raw `TypeError` or `AttributeError` errors.

### Task 2: Validate Traversed Collections

**Files:**
- Modify: `scripts/select_tvos_destination.py`
- Modify: `tests/test_select_tvos_destination.py`

1. Add minimal object-map and object-array validators.
2. Apply them immediately before each collection is traversed.
3. Run focused and complete portable selector tests.

### Task 3: Preserve The Contract

**Files:**
- Modify: `AGENTS.md`
- Modify: `README.md`
- Modify: `SECURITY.md`
- Modify: `VISION.md`
- Modify: `CHANGES.md`
- Modify: `scripts/check_tvos_contracts.py`
- Modify: `docs/plans/2026-06-26-simctl-collection-shape.md`

1. Document stable nested collection failures.
2. Add mutation-sensitive source, regression, fixture, guidance, and plan
   contracts.
3. Run `./scripts/run-make.sh check` and record platform skips honestly.
4. Validate hostile mutations, scan the current tree, and push a focused PR.

## Verification Completed

- The focused regression reproduced six raw `TypeError` or `AttributeError`
  failures, then passed after collection validation was added.
- All eight portable selector tests passed.
- `./scripts/run-make.sh check` passed Make authority checks, static contracts,
  and portable tests; tvOS XCTest and compilation skipped because Xcode is not
  available on this Linux host.
- This is the repository's trusted `make check` verification path.
- Seven isolated hostile mutations were rejected for missing runtime/device
  validation, changed failure messages, removed regression/fixture coverage,
  stale public guidance, and incomplete plan status.
- Python compileall, diff whitespace validation, and current-tree gitleaks
  completed without findings.
