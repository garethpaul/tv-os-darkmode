# Make Authority Hardening

## Status: Completed

## Context

The repository root was protected, but command-line `PYTHON` values still
allowed GNU Make function expansion and caller-provided shell or execution-mode
flags could change what `make check` actually executed.

## Requirements

- Preserve literal `PYTHON=/absolute/path` customization.
- Reject Make-syntax interpreter values before expansion.
- Keep repository roots and recipe shells under repository control.
- Reject caller `MAKEFLAGS` values that skip checks and stop verification when
  `MAKEFILES` is populated.
- Reject command-line `MAKEFILE_LIST` values that redirect root derivation.
- Prove the behavior from both repository and external working directories.
- Preserve Swift, tvOS, Xcode, destination, derived-data, and signing behavior.

## Work Completed

- Added repository-owned Make authority variables and target-specific overrides.
- Added adversarial tests for root, shell, Python, flags, Makefile identity, and
  startup makefiles.
- Wired the authority suite into `make check` without changing app behavior.

## Verification

- `make check` passes on portable hosts and reports Xcode skips truthfully.
- External-directory `make -f /path/to/Makefile check` runs the same gates.
- Hosted Xcode remains authoritative for tvOS build and XCTest behavior.

## Scope Boundaries

This change does not modify Swift source, UI behavior, accessibility behavior,
project settings, schemes, workflows, SDK versions, publishing, or deployment.
GNU Make evaluates startup files while parsing, before this Makefile can reject
them. Caller-supplied later `-f` files and parse-time startup side effects remain
outside the repository Make trust boundary.
