# Appearance Change Announcement

Status: Completed

## Goal

Notify VoiceOver users when the app's visible light, dark, or fallback
appearance state changes at runtime.

## Implementation

- Post an accessibility announcement after an actual interface-style change.
- Announce the same text exposed by the appearance label.
- Keep initial view loading quiet and preserve the no-op trait-change guard.
- Extend static contracts and manual verification guidance for the announcement.

## Verification

- `make check`
- Hosted Xcode tvOS Simulator build
- Mutation check: removing the accessibility post must fail the static
  appearance contract.
