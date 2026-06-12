# Modern Xcode Build Baseline

## Status: Completed

## Context

The sample still declared Swift 3 and tvOS 10, used renamed UIKit symbols, and
was never compiled by hosted verification. Linux contracts could therefore
pass even when the checked-in project no longer built with a supported Xcode.

## Objectives

- Move the project to a conservative Swift 5 and tvOS 12 baseline.
- Use the modern Swift application entry point, launch-options type, and
  accessibility trait syntax.
- Compile the tvOS simulator target with Xcode 16.4 on every push and pull
  request without code signing.
- Keep portable verification available on Linux and from any working directory.
- Enforce the toolchain, fixed runners, immutable actions, and build command in
  the static contract checker.
- Keep hosted compilation unsigned with `CODE_SIGNING_ALLOWED=NO`.

## Work Completed

- Updated both Xcode target configurations to Swift 5 and both project
  configurations to a tvOS 12 deployment target.
- Converted `AppDelegate` to `@main`, modern launch options, and removed unused
  lifecycle stubs.
- Modernized the appearance controller's Swift and accessibility syntax.
- Added a macOS 15 job using Xcode 16.4 and a code-signing-disabled simulator
  build with an explicit generic tvOS Simulator destination, alongside the
  fixed Ubuntu 24.04 contract job. Both checkout steps disable credential
  persistence.
- Made Makefile paths resolve from the repository location.
- Added static and mutation coverage for all new guarantees.

## Verification

- `make check`
- `make -f /path/to/tv-os-darkmode/Makefile check` outside the repository
- Hosted Xcode 16.4 tvOS simulator build
- Swift-version, deployment-target, runner, action annotation, and Makefile
  path mutations rejected by the static checker
- `git diff --check`
