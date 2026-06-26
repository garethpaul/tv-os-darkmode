# Simctl Collection Shape Design

Status: Completed

## Problem

The selector validates the decoded JSON root, but it still assumes that the
`runtimes`, `devices`, and `devicetypes` members have the collection shapes
emitted by `simctl`. Valid JSON schema drift such as `null`, scalar entries, or
a non-object devices map escapes as `TypeError` or `AttributeError`, which
`main` does not classify as a controlled selector failure.

## Options Considered

1. Catch `TypeError` and `AttributeError` in `main`. This hides programming
   mistakes anywhere in the selector and reports them as upstream data errors.
2. Fully model every `simctl` field. This is unnecessary for choosing a
   destination and would tightly couple the sample to undocumented fields.
3. Validate only the collection boundaries traversed by the selector. Require
   object entries in the relevant arrays and an object devices map, while
   preserving the existing permissive handling of optional scalar fields.

## Decision

Use small local validators for arrays of objects and object maps. Validate each
collection immediately before traversal so malformed nested structures raise a
stable `RuntimeError` without broad exception catching or behavior changes for
valid `simctl` payloads.

## Verification

Portable unit tests cover malformed containers and entries for runtimes,
devices, and device types. Static contracts preserve the validators, failure
messages, fixtures, guidance, and implementation plan. The completed change
must pass `make check` before merge.
