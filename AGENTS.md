# AGENTS.md

## Repository purpose

`garethpaul/tv-os-darkmode` is an Apple platform application or Objective-C/Swift sample. Implementing tvOS changes for dark/light mode

## Project structure

- `Makefile` - repository verification targets
- `scripts` - baseline checks and helper scripts
- `docs` - plans, notes, and generated README assets
- `tvos-darkmode.xcodeproj` - Xcode project
- `plans` - repository source or sample assets
- `tvos-darkmode` - repository source or sample assets

## Development commands

- Install dependencies: no repository-specific install command is documented.
- Full baseline: `make check`
- Combined verification: `make verify`
- Lint/static checks: `make lint`
- Tests: `make test` (runs static contracts everywhere and XCTest when Xcode is available)
- Build: `make build`
- Local Apple development: `open tvos-darkmode.xcodeproj`
- If a command above skips because a platform toolchain is missing, verify on a machine with that SDK before claiming platform behavior is tested.

## Coding conventions

- Language mix noted in the README: Swift (2).
- Preserve legacy Xcode project settings and signing assumptions unless the change is explicitly about modernization.

## Testing guidance

- `tvos-darkmodeTests/AppearancePresentationTests.swift` covers the light,
  dark, and fallback appearance mapping with XCTest.
- Start with the narrowest relevant test or Make target, then run `make check` before handing off if the change is not documentation-only.
- Keep README verification notes in sync when commands, fixtures, or supported toolchains change.

## PR / change guidance

- Keep diffs focused on the requested repository and avoid unrelated modernization or formatting churn.
- Preserve public APIs, sample behavior, file formats, and documented environment variables unless the task explicitly changes them.
- Update tests, README notes, or docs/plans when behavior, security posture, or validation commands change.
- Call out skipped platform validation, legacy toolchain assumptions, and any risky files touched in the final summary.

## Safety and gotchas

- No required secret or credential file was identified in the repository scan. If you add integrations later, keep secrets out of git.
- This looks like an Apple platform project or sample. Xcode, Swift, CocoaPods, and deployment target versions may need to match the original project era.
- See `SECURITY.md` for vulnerability reporting and safe research guidance.
- See `VISION.md` for project direction and contribution guardrails.
- See `docs/plans/2026-06-08-tvos-darkmode-baseline.md` for the canonical appearance-state baseline.
- See `docs/plans/2026-06-08-manual-appearance-verification.md` for the manual light/dark verification checklist.
- Simulator selection must not emit blank or non-string UDIDs; skip malformed
  discovered devices and fail closed on empty `simctl create` output.
- Non-object `simctl list --json` roots must fail through a stable selector
  error before runtime or device access.
- Malformed `simctl` runtime, device, and device-type collections must fail
  through stable selector errors before iteration.

## Agent workflow

1. Inspect the README, Makefile, manifests, and the files directly related to the request.
2. Make the smallest source or docs change that satisfies the task; avoid generated, vendored, or local-environment files unless required.
3. Run the narrowest useful validation first, then `make check` or the documented package/platform gate when available.
4. If a required SDK, service credential, or external runtime is unavailable, record the skipped command and why.
5. Summarize changed files, commands run, and remaining risks or follow-up validation.
