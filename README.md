<div align="center">

<img src="docs/demo.svg" alt="SmartSelect: double-click grabs the whole email instead of half of it" width="720">

# SmartSelect

### Double-click still selects — it just stops chopping things in half.

Native macOS double-click grabs `jane` out of `jane.doe@acme.co`, `1` out of `$1,299.00`, one path segment out of `~/Projects/app/main.swift`. **SmartSelect snaps the selection to the whole meaningful thing** — email, number, URL, date, IP, file path, hex color, @handle — the instant you double-click. Same gesture. Same `Cmd+C`. Zero new UI.

[![CI](https://github.com/smartselecthq/SmartSelect/actions/workflows/ci.yml/badge.svg)](https://github.com/smartselecthq/SmartSelect/actions/workflows/ci.yml)
[![Platform](https://img.shields.io/badge/platform-macOS%2012%2B-black?logo=apple)](https://www.apple.com/macos/)
[![Swift](https://img.shields.io/badge/Swift-5.9-orange?logo=swift)](https://swift.org)
[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)
[![PRs Welcome](https://img.shields.io/badge/PRs-welcome-brightgreen.svg)](CONTRIBUTING.md)

</div>

---

## The 40-year-old papercut

You have rage-dragged to fix a double-click that grabbed half an email address thousands of times. So has everyone. Double-click has snapped to the wrong boundary — the first dot, comma, `@`, or slash — since the first mouse shipped, and nobody ever fixed it.

SmartSelect fixes it. When you double-click inside a *structured* value, it expands the OS selection out to the whole entity. When you double-click a plain word, nothing changes — it stays out of your way.

```
double-click  jane.doe@acme.co   →   jane.doe@acme.co     (whole email)
double-click  $1,299.00          →   $1,299.00            (whole amount)
double-click  192.168.1.1        →   192.168.1.1          (whole IP)
double-click  2026-09-19         →   2026-09-19           (whole date)
double-click  ~/Projects/app.swift → ~/Projects/app.swift (whole path)
double-click  #1E90FF            →   #1E90FF              (whole hex color)
double-click  @typesafeai        →   @typesafeai          (whole handle)
```

## What it recognizes

| Kind | Example | Native double-click grabs | SmartSelect grabs |
|------|---------|---------------------------|-------------------|
| Email | `jane.doe@acme.co` | `jane` | the whole address |
| Number / amount | `$1,299.00`, `12.5%`, `1_000_000` | `1` | the whole number |
| URL | `https://example.com/pricing?ref=hn` | `example` | the whole URL |
| IP address | `192.168.1.1` | `168` | the whole address |
| Date & time | `2026-09-19`, `09/19/2026` | `2026` | the whole date |
| File path | `~/Projects/app/main.swift` | `main` | the whole path |
| Hex color | `#1E90FF` | `1E90FF` | the whole color |
| @handle / #tag | `@typesafeai`, `#SmartSelect` | `typesafeai` | the whole handle |

Every kind is individually toggleable from the menu bar.

## Install

### Homebrew (recommended)

```bash
brew install --cask smartselect
```

> The cask is published from [`Casks/smartselect.rb`](Casks/smartselect.rb). Until it lands in a tap, build from source:

### Build from source

```bash
git clone https://github.com/smartselecthq/SmartSelect.git
cd SmartSelect
make app          # builds SmartSelect.app into ./build
open build/SmartSelect.app
```

On first launch, macOS asks for **Accessibility** access (System Settings → Privacy & Security → Accessibility). SmartSelect needs it to observe double-clicks and adjust the selection. That's the only permission it ever requests.

## Privacy

**100% on-device. No network. No telemetry. No accounts.** SmartSelect never sends a single byte anywhere — the entire entity-boundary engine is plain, local pattern-matching ([`SmartSelectCore`](Sources/SmartSelectCore)). Read the code; there is no networking anywhere in the repository.

## How it works

SmartSelect is two cleanly separated layers:

- **[`SmartSelectCore`](Sources/SmartSelectCore)** — a pure, dependency-free, fully unit-tested engine. Given a line of text and the range the OS just selected, it returns the enclosing entity's range. No platform APIs, so it runs (and is tested) on Linux CI as well as macOS.
- **[`SmartSelectApp`](Sources/SmartSelectApp)** — a menu-bar agent that wires the engine to macOS:
  1. A listen-only [`CGEventTap`](Sources/SmartSelectApp/EventTapController.swift) observes double-clicks (it never swallows or alters events).
  2. After a ~40 ms settle, the [Accessibility bridge](Sources/SmartSelectApp/AccessibilityBridge.swift) reads the focused element's value and current selection.
  3. The engine expands the selection within the enclosing line.
  4. If it widened, the new range is written back via `kAXSelectedTextRangeAttribute`.

Everything is done in **UTF-16 offsets** end-to-end, the unit shared by `NSRegularExpression` and the Accessibility API, so there are no lossy conversions between "detect" and "re-select."

```
double-click → CGEventTap → AccessibilityBridge (read) → SelectionExpander (Core) → AccessibilityBridge (write)
```

## Compatibility

Works in any app that exposes standard AX text attributes — native Cocoa apps, most text fields, Notes, Mail, and similar. Some browsers and Electron apps expose selection ranges inconsistently; support there is best-effort and tracked in the [roadmap](#roadmap).

## Development

```bash
make test     # run the SmartSelectCore test suite
make build    # debug build of the executable
make app      # bundle a runnable SmartSelect.app
make lint     # swiftlint (if installed)
make format   # swift-format (if installed)
```

The engine is the interesting part to hack on — adding a new entity kind is a new pattern in [`EntityPatterns.swift`](Sources/SmartSelectCore/EntityPatterns.swift), a case in [`EntityKind`](Sources/SmartSelectCore/EntityKind.swift), and a test.

## Roadmap

- [ ] Homebrew cask in a public tap
- [ ] Signed & notarized release builds
- [ ] Triple-click → whole *sentence* / *statement* snapping
- [ ] Learned/custom entity patterns (regex you define)
- [ ] Better coverage for Chromium & Electron selection quirks
- [ ] Launch-at-login toggle

## Contributing

PRs are genuinely welcome — see [CONTRIBUTING.md](CONTRIBUTING.md). Good first issues: new entity detectors (currency codes, phone numbers, git SHAs, semver) with tests.

## Credits

Inspired by [**@typesafeai** (jev)](https://twitter.com/typesafeai) and the "smart copy/paste" idea — the notion that the primitive interactions we do a thousand times a day are exactly the ones worth making intelligent, without changing the gesture at all. SmartSelect applies that lens to double-click selection.

## License

[MIT](LICENSE) © Swathi
