# Simctl Root Shape Implementation Plan

Status: Completed

> **For Claude:** REQUIRED SUB-SKILL: Use executing-plans to implement this plan task-by-task.

**Goal:** Fail with a stable selector error when `simctl list --json` decodes to a non-object root.

**Architecture:** Keep schema validation at the start of `select_destination`, before any `.get` access. Accept only the dictionary shape emitted by `simctl`; convert JSON `null`, arrays, strings, numbers, and booleans into one local `RuntimeError` that `main` already reports without a traceback.

**Tech Stack:** Python 3.12, `unittest`, Xcode `simctl`, GNU Make, GitHub Actions.

---

### Task 1: Prove The Raw Attribute Failure

**Files:**
- Modify: `tests/test_select_tvos_destination.py`

**Step 1: Write the failing test**

Add a table-driven regression for `None`, `[]`, `"devices"`, `0`, and `False`, expecting `RuntimeError("simctl list response must be an object")` before device creation.

**Step 2: Run test to verify it fails**

Run: `python3 -m unittest tests.test_select_tvos_destination.SelectTVOSDestinationTests.test_rejects_non_object_simctl_root`

Expected: FAIL because `select_destination` currently calls `.get` on the malformed root.

### Task 2: Guard The Root Boundary

**Files:**
- Modify: `scripts/select_tvos_destination.py`
- Modify: `tests/test_select_tvos_destination.py`

**Step 1: Write minimal implementation**

Add `if not isinstance(payload, dict): raise RuntimeError("simctl list response must be an object")` as the first statement in `select_destination`.

**Step 2: Run focused tests**

Run: `python3 -m unittest tests.test_select_tvos_destination.SelectTVOSDestinationTests.test_rejects_non_object_simctl_root`

Expected: PASS.

### Task 3: Preserve The Durable Contract

**Files:**
- Modify: `AGENTS.md`
- Modify: `README.md`
- Modify: `SECURITY.md`
- Modify: `VISION.md`
- Modify: `CHANGES.md`
- Modify: `scripts/check_tvos_contracts.py`
- Modify: `docs/plans/2026-06-26-simctl-root-shape.md`

**Step 1: Document the boundary**

State that non-object `simctl` roots fail through a stable selector error before runtime/device access.

**Step 2: Add mutation-sensitive contracts**

Require the root guard before the first payload access, the regression name and fixtures, synchronized guidance, and completed plan evidence.

**Step 3: Run complete verification**

Run: `./scripts/run-make.sh check`

Expected: portable selector tests, static contracts, Make authority checks, and hosted Xcode verification remain green.
This trusted wrapper is the repository's canonical `make check` boundary.

**Step 4: Commit**

Run: `git add scripts/select_tvos_destination.py tests/test_select_tvos_destination.py scripts/check_tvos_contracts.py AGENTS.md README.md SECURITY.md VISION.md CHANGES.md docs/plans/2026-06-26-simctl-root-shape.md && git commit -m "fix: validate simctl response root"`

## Verification Completed

- The focused regression failed for all five non-object JSON roots with raw
  `AttributeError`, then passed after the root guard was added.
- `./scripts/run-make.sh check` passed Make authority checks, eight static
  contract groups, and all seven portable selector tests.
- tvOS XCTest and simulator compilation skipped honestly because Xcode is not
  available on the Linux host; hosted Xcode 16.4 remains required.
- Seven isolated hostile mutations were rejected for missing/wrong/late root
  validation, missing regression naming, incomplete fixture coverage, removed
  public guidance, and stale plan status.
