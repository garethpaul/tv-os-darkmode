# Executable Appearance Tests

## Status: Completed

## Context

Hosted macOS verification compiles the tvOS application, but the project has no
test target and `make test` only repeats static contracts. The light, dark, and
fallback appearance mapping can therefore regress while every current gate
remains green.

## Objectives

- Exercise light, dark, and fallback appearance mapping with XCTest.
- Keep the controller's visible and accessibility behavior unchanged.
- Add a shared scheme that builds and executes the test bundle.
- Run XCTest in the canonical hosted macOS job without signing or credentials.
- Reject project, scheme, workflow, Makefile, test, and plan regressions with
  portable contracts.

## Scope

- Extract only the deterministic appearance presentation mapping needed for
  unit testing.
- Add a tvOS unit-test bundle and three focused behavior tests.
- Extend the existing Make and workflow gates from compile-only to XCTest.
- Do not add UI automation, snapshots, signing, device installation, or visual
  claims.

## Verification

- The implementation-specific source, project, shared-scheme, test, workflow,
  Makefile, and documentation contracts passed before plan completion.
- `python3 scripts/check_tvos_contracts.py` and `make check` passed locally;
  XCTest and the unsigned build reported explicit skips because Xcode is not
  installed on this Linux host.
- An absolute-path `make -f .../tv-os-darkmode/Makefile check` invocation
  passed from `/tmp`, confirming caller-directory independence.
- Seven hostile mutations were rejected across the appearance mapping, test
  source, unit-test target, shared scheme, simulator destination, workflow,
  and completed plan.
- Ruby Xcodeproj parsing confirmed both native targets, test source membership,
  the app-target dependency, Debug/Release test-host settings, and the shared
  scheme structure.
- `python3 -m py_compile scripts/check_tvos_contracts.py` and
  `git diff --check` passed.
- GitHub Actions run 27422477268 passed `static-contracts` and `xcode-test` at
  implementation head `b35be8cbd9cf353d10adbe00872a96902c1a6638`.
- Xcode 16.4 executed all three appearance tests on the pinned tvOS 18.5
  simulator with zero failures and reported `TEST SUCCEEDED`.
