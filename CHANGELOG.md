# Changelog

All notable changes to this project are documented here.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added
- Initial release of SmartSelect.
- `SmartSelectCore`: pure entity-boundary engine with detectors for email, URL,
  IP address, date/time, hex color, file path, @handle, and number/amount.
- Line-windowing so detection stays fast on large documents.
- `SmartSelectApp`: menu-bar agent using a listen-only `CGEventTap` and the
  Accessibility API to expand the live selection on double-click.
- Per-entity-kind toggles and a global enable/disable switch in the menu bar.
- Full unit-test suite for the core engine.

[Unreleased]: https://github.com/smartselecthq/SmartSelect/commits/main
