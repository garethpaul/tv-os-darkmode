## tvOS Dark Mode Vision

tvOS Dark Mode is a small Swift sample that observes trait collection changes
and distinguishes light and dark user interface styles.

The repository is useful as a minimal tvOS project for detecting appearance
changes through focused modern trait registration with a legacy deployment-
floor fallback.

The goal is to keep the sample focused on interface-style detection and make
the supported tvOS/Xcode context clear.

The current focus is:

Priority:

- Preserve the trait-collection appearance detection example
- Keep light/dark behavior easy to inspect
- Avoid adding unrelated app UI
- Treat the project as a minimal sample
- Keep the visible appearance state in sync with trait changes
- Keep the appearance state readable and accessible
- Keep appearance labels identifiable as static text to assistive technologies
- Keep appearance labels display-only and non-interactive
- Keep appearance labels described for assistive technologies
- Announce live appearance changes to assistive technologies
- Avoid duplicate announcements during initial or unchanged appearance callbacks
- Announce hidden or inactive appearance changes once when presentation resumes
- Keep UI state ownership on the main actor
- Use the scene lifecycle on tvOS 13+ while preserving the tvOS 12 fallback
- Keep the root appearance view identifiable for simulator/UI verification
- Keep appearance text scaled within the tvOS viewport
- Keep appearance text bounded inside the tvOS viewport
- Keep foreground and background appearance colors paired explicitly
- Keep app delegate signatures aligned with the checked-in Swift version
- Keep the Swift 5 and tvOS 12 project baseline buildable with Xcode 16.4
- Keep light, dark, and fallback appearance mapping covered by hosted XCTest
- Keep dark and light controller hierarchy rendering covered by hosted XCTest
- Keep loaded-controller dark-to-light and light-to-dark rendering covered by
  hosted XCTest
- Keep tvOS simulator destination identifiers non-empty and validated before
  invoking `xcodebuild`
- Keep focused tvOS 17 trait registration with a tvOS 12 through 16 fallback
- Keep Reduce Motion behavior animation-free and retain maximum-contrast color pairs
- Keep completed maintenance plans under `docs/plans`
- Keep GitHub Actions running both portable contracts and hosted XCTest through
  the fixed sanitized Make wrapper

Next priorities:

- Add device or simulator screenshots for light and dark appearances
- Add simulator-backed UI verification and screenshots
- Validate the modern and legacy trait-observation paths on supported Apple
  platform versions

Contribution rules:

- One PR = one focused appearance, UI, project, or documentation change.
- Keep the sample minimal.
- Include simulator or device notes for behavior changes.
- Keep `.github/workflows/check.yml` aligned with the static and XCTest
  baselines.
- Avoid adding services or persistence.

## Security And Responsible Use

Canonical security policy and reporting:

- [`SECURITY.md`](SECURITY.md)

This sample should remain local and UI-only. It should not introduce network,
tracking, or device data collection behavior.

## What We Will Not Merge (For Now)

- Hidden analytics
- Unrelated feature expansion
- Network dependencies
- Appearance labels that can overflow the viewport
- Legacy Swift application entry points or launch-options types
- Appearance changes without a verification note

This list is a roadmap guardrail, not a permanent rule.
Strong user demand and strong technical rationale can change it.
