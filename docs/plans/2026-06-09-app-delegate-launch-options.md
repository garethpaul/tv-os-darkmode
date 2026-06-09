# App Delegate Launch Options Signature

## Status: Completed

## Context

The Xcode project pins `SWIFT_VERSION = 3.0`, but `AppDelegate` still used the
pre-Swift-3 launch-options type `[NSObject: AnyObject]?`. That can leave the
sample with a stale delegate callback signature relative to its checked-in
Swift compiler setting.

## Objectives

- Align the app delegate launch callback with the Swift 3 UIKit signature.
- Keep the app delegate behavior unchanged.
- Add a static tvOS contract so the legacy launch-options type does not return.
- Document the compatibility guard in the repository plans.

## Work Completed

- Updated `didFinishLaunchingWithOptions` to use
  `[UIApplicationLaunchOptionsKey: Any]?`.
- Added `check_app_delegate_contracts()` to the tvOS static verifier.
- Extended docs-plan requirements to include this completed plan.
- Updated README, VISION, and CHANGES.

## Verification

- Negative: source review showed the old `[NSObject: AnyObject]?` launch-options
  type while the project declares Swift 3.
- `python3 scripts/check_tvos_contracts.py`
- `make check`
- `make verify`
- `git diff --check`

`xcodebuild` is not installed in this environment, so the Makefile build step
reported the expected static-only verification fallback.

## Follow-Up Candidates

- Verify the project on a tvOS simulator when Xcode is available.
- Audit other app delegate callbacks during a dedicated Swift modernization
  pass.
