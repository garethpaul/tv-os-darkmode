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

Next priorities:

- Add a README with setup and expected console output
- Add a visible UI state change instead of only printing
- Document supported tvOS and Xcode versions
- Add a manual verification checklist for appearance changes

Contribution rules:

- One PR = one focused appearance, UI, project, or documentation change.
- Keep the sample minimal.
- Include simulator or device notes for behavior changes.
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
- Appearance changes without a verification note

This list is a roadmap guardrail, not a permanent rule.
Strong user demand and strong technical rationale can change it.
