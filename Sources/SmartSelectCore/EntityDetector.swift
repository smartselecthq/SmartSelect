import Foundation

/// Finds the single entity of a given ``EntityKind`` that fully contains a hit range.
///
/// A detector is stateless and thread-safe: it receives the surrounding text and the
/// range the user's double-click landed on, and returns the range of the entity that
/// encloses that hit — or `nil` if the hit is not inside an entity of this kind.
public protocol EntityDetector: Sendable {
    var kind: EntityKind { get }

    /// - Parameters:
    ///   - text: The text to search (typically the line enclosing the selection).
    ///   - hit: The current selection, in UTF-16 offsets relative to `text`.
    /// - Returns: The UTF-16 range of the enclosing entity, or `nil`.
    func match(in text: String, containing hit: NSRange) -> NSRange?
}

/// An ``EntityDetector`` backed by a single `NSRegularExpression`.
///
/// `NSRegularExpression` (rather than Swift's `Regex`) is used intentionally: it operates
/// in UTF-16 space to match ``TextSpan`` and the Accessibility API, and it compiles and
/// runs identically on macOS and on Linux CI.
///
/// - Note: `@unchecked Sendable` is required because Linux's swift-corelibs-foundation
///   does not mark `NSRegularExpression` as `Sendable` (Apple's Foundation does). The type
///   is documented as thread-safe once compiled, and this detector only ever reads from it,
///   so the unchecked conformance is sound.
public struct RegexEntityDetector: EntityDetector, @unchecked Sendable {
    public let kind: EntityKind
    private let regex: NSRegularExpression

    /// - Note: Traps on an invalid pattern. Patterns are compile-time constants defined
    ///   in this module and covered by tests, so an invalid one is a programmer error that
    ///   should fail loudly rather than silently disable a detector in the field.
    public init(kind: EntityKind, pattern: String, options: NSRegularExpression.Options = []) {
        self.kind = kind
        do {
            self.regex = try NSRegularExpression(pattern: pattern, options: options)
        } catch {
            preconditionFailure("Invalid regex for \(kind): \(error)")
        }
    }

    public func match(in text: String, containing hit: NSRange) -> NSRange? {
        let full = NSRange(text.startIndex..., in: text)
        var found: NSRange?
        regex.enumerateMatches(in: text, options: [], range: full) { result, _, stop in
            guard let range = result?.range, range.location != NSNotFound else { return }
            if range.fullyContains(hit) {
                found = range
                stop.pointee = true
            }
        }
        return found
    }
}
