import Foundation

/// A range of text expressed in **UTF-16 code-unit offsets**.
///
/// UTF-16 is deliberate: it is the unit used by both `NSString`/`NSRegularExpression`
/// and the macOS Accessibility API (`kAXSelectedTextRangeAttribute` carries a `CFRange`
/// in UTF-16). Keeping the engine in the same unit end-to-end means zero lossy conversions
/// between detecting an entity and re-selecting it on screen.
public struct TextSpan: Equatable, Hashable, Sendable {
    public var location: Int
    public var length: Int

    public init(location: Int, length: Int) {
        self.location = location
        self.length = length
    }

    /// The exclusive upper bound (`location + length`).
    public var upperBound: Int { location + length }

    public var isEmpty: Bool { length == 0 }

    /// `true` when `other` lies entirely within (or is equal to) this span.
    public func contains(_ other: TextSpan) -> Bool {
        other.location >= location && other.upperBound <= upperBound
    }
}

// MARK: - NSRange bridging

public extension TextSpan {
    init(_ range: NSRange) {
        self.init(location: range.location, length: range.length)
    }

    var nsRange: NSRange {
        NSRange(location: location, length: length)
    }
}

extension NSRange {
    /// `true` when `other` is fully contained within the receiver.
    func fullyContains(_ other: NSRange) -> Bool {
        guard location != NSNotFound, other.location != NSNotFound else { return false }
        return other.location >= location && (other.location + other.length) <= (location + length)
    }
}
