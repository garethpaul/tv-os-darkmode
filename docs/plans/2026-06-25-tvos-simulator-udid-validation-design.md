# tvOS Simulator UDID Validation Design

Status: Completed

## Problem

The hosted XCTest destination selector trusts the `udid` field from `simctl`
and the output of `simctl create`. A missing or blank value produces
`platform=tvOS Simulator,id=` and defers the failure to `xcodebuild`, where the
result is less specific and harder to diagnose.

## Options Considered

1. Validate only in the workflow shell. This duplicates selector policy and
   leaves direct callers unsafe.
2. Require a UUID-shaped identifier. This is stricter than the selector needs
   and could reject future valid simulator identifier formats.
3. Accept only non-empty string identifiers in the selector. Skip malformed
   existing devices and reject malformed creation output immediately.

## Decision

Use one helper that trims and validates non-empty string UDIDs. Existing devices
without a usable identifier are ignored so the selector can create the reviewed
device type. Empty creation output raises a stable `RuntimeError` before any
destination string is emitted.

## Verification

Portable unit tests cover blank existing and created identifiers. Static
contracts preserve the helper and hostile cases, while hosted macOS continues
to exercise the real `simctl` and `xcodebuild` path. The completed change must
pass `make check` before merge.
