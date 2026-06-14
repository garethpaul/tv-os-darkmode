# Make Root Override Protection

## Status: Planned

## Context

The Makefile derives an absolute repository root so static, XCTest, and build
aliases can run from outside the checkout. Its ordinary GNU Make assignment can
still be replaced by an environment or command-line `ROOT`, redirecting the
repository checker and Xcode working paths to another tree while a command
appears to verify this checkout.

Python and simulator destination selection are intentionally configurable.
Repository ownership is not: every source, project, scheme, test, and evidence
path must remain anchored to the checkout containing the invoked Makefile.

## Requirements

- Protect the derived repository root from environment and command-line
  reassignment.
- Preserve explicit `PYTHON` and `TVOS_DESTINATION` overrides and all five
  public aliases.
- Prove repository and external working-directory invocations remain anchored
  under hostile root assignments.
- Add mutation-sensitive contracts for the declaration, assignment count and
  order, aliases, checker/Xcode paths, README index, and completed plan.
- Preserve Swift, Xcode, tvOS appearance, accessibility, workflow, CodeQL, and
  SDK behavior.

## Approach

Apply GNU Make's `override` directive only to the existing immediate root
assignment. Keep it before the configurable interpreter and simulator
destination declarations. Extend the canonical tvOS checker and use bounded
dry-run cases to exercise GNU Make precedence without bypassing hosted Xcode.

## Implementation Units

### Protect repository path ownership

- Update `Makefile` so exactly one protected root declaration owns repository
  paths.
- Retain the existing alias graph and both supported tool/destination overrides.

### Add adversarial contracts

- Extend `scripts/check_tvos_contracts.py` with declaration-count, ordering,
  alias, checker/Xcode-path, README, and plan requirements.
- Run all five aliases from repository and external directories under hostile
  environment and command-line root assignments.
- Reject declaration, duplication, ordering, alias, path, documentation, and
  plan-state mutations.

### Record completed evidence

- Index this plan from `README.md`.
- Mark it completed only after focused, mutation, full static, review, artifact,
  secret, and exact-diff validation succeeds.

## Risks And Mitigations

- Protecting the destination or interpreter would prevent supported validation
  customization. Only `ROOT` becomes protected; both configurable declarations
  stay unchanged and receive explicit override checks.
- A declaration-only assertion could miss a later reassignment or alias bypass.
  Count all assignments and require the complete alias graph plus
  repository-owned command paths.
- Local Linux cannot execute tvOS builds or XCTest. Run the complete static gate
  locally and retain hosted Xcode as the native exact-head authority.

## Scope Boundaries

This change does not modify Swift logic, controller lifecycle, trait handling,
VoiceOver behavior, storyboard/assets, project settings, schemes, tests,
workflow policy, CodeQL, SDK versions, or deployment behavior.

## Verification Plan

- Run focused static contracts and Make dry-run checks.
- Exercise all aliases from two working directories under hostile root
  assignments while preserving explicit interpreter and destination selection.
- Reject eight focused structural and evidence mutations.
- Run `make check` with an explicit timeout and document local Xcode availability.
- Review the exact plan-scoped diff and audit generated artifacts, changed-line
  secrets, whitespace, and protected Swift/project/workflow paths.
