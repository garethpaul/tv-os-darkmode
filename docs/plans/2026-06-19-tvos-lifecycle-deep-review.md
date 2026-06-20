# tvOS Lifecycle Deep Review

Status: Completed

## Scope

Review the stacked appearance PRs through the controller, trait observation,
application lifecycle, accessibility, Xcode project, Make entry points, and
hosted workflows.

## Findings

- The default `make test` destination pinned tvOS 18.5, so it failed before
  compilation when a newer Xcode only supplied tvOS 26.
- Trait changes always posted an accessibility announcement, including while
  the controller was hidden or the app was inactive.
- Building with the tvOS 26 SDK reported that the scene lifecycle will become
  mandatory after the current SDK generation.
- The existing explicit black/white and dark-gray/white pairs remain suitable
  for increased contrast, and the sample has no animations to adapt for Reduce
  Motion.

## Design

Keep appearance mapping separate from a small deterministic transition state.
Every changed style renders immediately. The state records the last style
communicated to the user and only emits an announcement when the controller is
visible and the application is active. Hidden or inactive changes remain
pending until presentation resumes, and a round trip back to the communicated
style produces no redundant announcement.

Use `registerForTraitChanges` on tvOS 17+, retain the legacy callback below
tvOS 17, and route both through the same state owner. Adopt a storyboard-backed
`SceneDelegate` on tvOS 13+ while preserving the app-delegate/storyboard
fallback for tvOS 12. Keep the hosted toolchain fixed, but let local Make select
the named simulator runtime supplied by the selected Xcode.

## Verification

- New state tests were observed failing before the transition types existed.
- Twelve presentation, state, and controller XCTest cases passed on Xcode
  26.0.1/tvOS 26.
- The scene lifecycle removed the tvOS 26 launch warning.
- `make check` passed from the repository root, and the static gate passed from
  `/tmp` with a hostile `ROOT=/tmp` override.
- Six targeted mutations were rejected: initial-baseline loss, visibility or
  activity gating, duplicate-style rendering, hard-coded runtime restoration,
  scene-manifest removal, and main-actor removal.
- Redacted Gitleaks scans found no credentials in the current tree or all 48
  commits. GitHub reported zero open code-scanning, secret-scanning, and
  Dependabot alerts.
- Hosted Check and CodeQL: required before merge.
