import Foundation

/// The regular-expression patterns backing the built-in detectors.
///
/// Kept in one place so the boundary rules are auditable and testable in isolation.
/// Each pattern is written to match a *complete* entity so the detector can expand a
/// partial double-click selection out to the whole thing.
enum EntityPatterns {
    /// `jane.doe@acme.co`
    static let email = #"[A-Za-z0-9._%+\-]+@[A-Za-z0-9](?:[A-Za-z0-9\-]*[A-Za-z0-9])?(?:\.[A-Za-z0-9](?:[A-Za-z0-9\-]*[A-Za-z0-9])?)*\.[A-Za-z]{2,}"#

    /// `https://example.com/x?y=1`, `www.example.com`
    static let url = #"(?:https?://|www\.)[A-Za-z0-9\-._~:/?#\[\]@!$&'()*+,;=%]+[A-Za-z0-9/#]"#

    /// Dotted-quad IPv4, each octet 0–255.
    static let ipAddress = #"\b(?:(?:25[0-5]|2[0-4][0-9]|1[0-9][0-9]|[1-9]?[0-9])\.){3}(?:25[0-5]|2[0-4][0-9]|1[0-9][0-9]|[1-9]?[0-9])\b"#

    /// ISO dates/datetimes, `M/D/Y`, `Mon D, YYYY`, and clock times.
    static let dateTime: String = {
        let iso = #"\d{4}-\d{2}-\d{2}(?:[T ]\d{2}:\d{2}(?::\d{2})?)?"#
        let slashed = #"\d{1,2}/\d{1,2}/\d{2,4}"#
        let monthName = #"(?:Jan|Feb|Mar|Apr|May|Jun|Jul|Aug|Sep|Oct|Nov|Dec)[a-z]*\.?\s+\d{1,2}(?:,\s*\d{4})?"#
        let clock = #"\d{1,2}:\d{2}(?::\d{2})?\s?(?:[AaPp][Mm])?"#
        return "\\b(?:\(iso)|\(slashed)|\(monthName)|\(clock))"
    }()

    /// `#1E90FF` or `#abc`.
    static let hexColor = #"#(?:[0-9A-Fa-f]{6}|[0-9A-Fa-f]{3})\b"#

    /// Unix (`~/a/b`, `/usr/local/bin`) and Windows (`C:\a\b`) paths.
    static let filePath = #"(?:[A-Za-z]:\\[\\\w.\- ]+|~?(?:/[\w.\-]+){2,}/?)"#

    /// `@handle` or `#hashtag` (letters, digits, underscore; at least two chars).
    static let handle = #"[@#][A-Za-z0-9_]{2,}"#

    /// Signed/curr­ency/percent numbers with optional thousands separators.
    /// The separator-bearing form is listed first so `1,299` wins over a bare `1`.
    static let number = #"[-+]?\$?\d{1,3}(?:[,_]\d{3})+(?:\.\d+)?%?|[-+]?\$?\d+(?:\.\d+)?%?"#
}
