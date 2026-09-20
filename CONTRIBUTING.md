# Contributing to SmartSelect

Thanks for wanting to make double-click smarter. Contributions of all sizes are welcome.

## Getting started

```bash
git clone https://github.com/smartselecthq/SmartSelect.git
cd SmartSelect
make test      # run the core test suite
make app       # build a runnable SmartSelect.app
```

You need macOS 12+ and a Swift 5.9 toolchain (Xcode 15 or the matching Command Line Tools).

## Project layout

- `Sources/SmartSelectCore/` — the pure, testable engine. **This is where most contributions land.**
- `Sources/SmartSelectApp/` — macOS menu-bar agent (event tap + Accessibility).
- `Tests/SmartSelectCoreTests/` — engine tests.

The engine has **no platform dependencies** and must stay that way — it is what lets us test
exhaustively and keep the boundary logic honest. Anything that touches AppKit, CoreGraphics,
or the Accessibility API belongs in `SmartSelectApp`.

## Adding a new entity kind

This is the best first contribution. To add, say, phone numbers:

1. Add a `case phoneNumber` to [`EntityKind`](Sources/SmartSelectCore/EntityKind.swift),
   with a `displayName` and `example`. Its position in the enum sets its detection priority.
2. Add a pattern to [`EntityPatterns`](Sources/SmartSelectCore/EntityPatterns.swift).
3. Wire it up in `SelectionExpander.detector(for:)`.
4. Add tests to `SelectionExpanderTests` — at least one positive expansion, one
   "already whole" no-op, and one case proving priority against a neighboring kind.

## Pull requests

- Keep PRs focused; one entity kind or one fix per PR is ideal.
- `make test` must pass and new behavior must be covered by tests.
- Match the existing style (`make format` / `make lint` if you have the tools).
- Update `CHANGELOG.md` under `[Unreleased]`.

## Reporting bugs

Open an issue using the **Bug report** template. A concrete before/after — the exact text,
where you double-clicked, what got selected, and what you expected — is worth a thousand words.

By contributing, you agree that your contributions are licensed under the [MIT License](LICENSE).
