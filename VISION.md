## tvOS Dark Mode Vision

tvOS Dark Mode is a small Swift sample that observes trait collection changes
and distinguishes light and dark user interface styles.

The repository is useful as a minimal tvOS project for detecting appearance
changes and wiring behavior to `traitCollectionDidChange`.

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
- Keep the root appearance view identifiable for simulator/UI verification
- Keep appearance text scaled within the tvOS viewport
- Keep appearance text bounded inside the tvOS viewport
- Keep foreground and background appearance colors paired explicitly
- Keep app delegate signatures aligned with the checked-in Swift version
- Keep the Swift 5 and tvOS 12 project baseline buildable with Xcode 16.4
- Keep light, dark, and fallback appearance mapping covered by hosted XCTest
- Keep completed maintenance plans under `docs/plans`
- Keep GitHub Actions running both portable contracts and hosted XCTest

Next priorities:

- Add device or simulator screenshots for light and dark appearances
- Add simulator-backed UI verification and screenshots
- Replace deprecated trait-change observation when the deployment floor allows

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
