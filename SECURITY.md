# Security Policy

## Reporting a vulnerability

Please report security issues privately using GitHub's
[**Report a vulnerability**](https://github.com/smartselecthq/SmartSelect/security/advisories/new)
flow rather than opening a public issue. We aim to acknowledge reports within 72 hours.

## Threat model

SmartSelect requires macOS **Accessibility** permission, which is a powerful grant: with it,
a process can observe input and read/modify UI elements system-wide. Because of that, the
project holds itself to a few hard rules:

- **No network access.** The app performs zero network I/O. The entire entity-detection
  engine (`SmartSelectCore`) is pure, local pattern-matching with no dependencies.
- **No persistence of your text.** Selected text is read, expanded in memory, and the new
  range is written back. Nothing is logged to disk or retained.
- **Listen-only event tap.** The `CGEventTap` is created with `.listenOnly` and never
  modifies, delays, or swallows your input events.

If you find behavior that contradicts any of the above, treat it as a security issue and
report it through the private flow.

## Scope

Supported: the latest released version on the `main` branch. Older tags are not patched.
