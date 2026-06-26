# tvOS Simulator UDID Validation Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use executing-plans to implement this plan task-by-task.

Status: Completed

**Goal:** Prevent the tvOS destination selector from emitting blank simulator identifiers.

**Architecture:** Keep simulator discovery and creation unchanged, but route both existing-device and creation results through one non-empty string validator before constructing the destination.

**Tech Stack:** Python 3.12, `xcrun simctl`, `unittest`, repository static contracts.

---

## Tasks

1. Add failing tests for blank existing and created UDIDs.
2. Add a shared normalized-UDID helper.
3. Skip malformed existing devices and reject malformed creation output.
4. Add static and documentation contracts.
5. Run portable, mutation, hosted, and review gates.

## Verification Completed

- The focused blank-ID unit tests failed before implementation; the completed
  matrix also covers non-string discovered and created identifiers.
- `make check` runs the portable selector suite and static contracts.
- A hostile mutation that returned blank normalized identifiers was rejected by
  both focused regressions.
- Hosted macOS XCTest remains the real `simctl` and destination integration gate.
