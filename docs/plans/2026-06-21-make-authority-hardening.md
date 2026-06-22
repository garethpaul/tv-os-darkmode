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
- Route hosted static and XCTest Make invocations through a fixed wrapper that
  accepts only the intended target and removes inherited Make control state.
- Reproduce real `--eval`, dry-run, ignore-errors, `GNUMAKEFLAGS`, startup-file,
  and earlier-`-f` authority before proving the wrapper blocks those paths.
- Prove the behavior from both repository and external working directories.
- Preserve Swift, tvOS, Xcode, destination, derived-data, and signing behavior.

## Work Completed

- Added repository-owned Make authority variables and target-specific overrides.
- Added adversarial tests for root, shell, Python, flags, Makefile identity, and
  startup makefiles.
- Added `scripts/run-make.sh` with fixed root/tool resolution, an exact
  `check|test` allowlist, sanitized Make environment, a bounded physical-script
  symlink resolver, and a fixed Makefile path.
- Changed both hosted Make invocations to use the wrapper.
- Wired the authority suite into `make check` without changing app behavior.

## Verification

- `./scripts/run-make.sh check` passes on portable hosts and reports Xcode
  skips truthfully.
- From an external working directory, `/path/to/scripts/run-make.sh check` runs
  the same gates against the physical repository root.
- External relative and absolute symlink invocation resolves back to the
  physical script; broken and chains beyond 40 links fail closed.
- Hosted Xcode remains authoritative for tvOS build and XCTest behavior.

## Scope Boundaries

This change does not modify Swift source, UI behavior, accessibility behavior,
project settings, schemes, workflows, SDK versions, publishing, or deployment.
Direct Make remains caller authority. GNU Make evaluates startup files, earlier
`-f` files, `--eval`, and execution-mode options before this Makefile can reject
or diagnose them. The trusted boundary begins at `scripts/run-make.sh`; callers
that execute code before the wrapper remain outside it.
