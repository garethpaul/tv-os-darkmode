# Appearance Label Accessibility Gate

## Problem

The sample now shows appearance state on screen, but the label did not declare
wrapping behavior or expose a stable accessibility identity. Longer fallback
states could truncate, and automated UI checks would not have a durable label
identifier.

## TDD Evidence

1. Extended `scripts/check_tvos_contracts.py` with appearance-label wrapping
   and accessibility requirements.
2. Ran `make lint` before changing `ViewController.swift` and confirmed the new
   check failed on the missing wrapping setup.
3. Added wrapping, accessibility identifier, and accessibility label updates,
   then reran the full verification gate.

## Verification

- `make lint`
- `make test`
- `make build`
- `make verify`
- `git diff --check`
