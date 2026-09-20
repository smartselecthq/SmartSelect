import Foundation

/// Slices out the line enclosing a selection so entity detection runs over a small,
/// relevant window instead of an entire (possibly huge) document.
public enum TextWindow {
    /// Returns the substring of `text` bounded by the newlines surrounding `span`,
    /// together with the UTF-16 offset of that window within `text`.
    ///
    /// Offsets in the returned window are `original - offset`; map results back with
    /// `original = windowResult + offset`.
    public static func enclosingLine(in text: String, around span: TextSpan) -> (window: String, offset: Int) {
        let ns = text as NSString
        let length = ns.length
        guard length > 0 else { return ("", 0) }

        let clampedStart = max(0, min(span.location, length))
        let clampedEnd = max(clampedStart, min(span.upperBound, length))

        var lineStart = 0
        var lineEnd = length
        var contentsEnd = length
        ns.getLineStart(&lineStart,
                        end: &lineEnd,
                        contentsEnd: &contentsEnd,
                        for: NSRange(location: clampedStart, length: clampedEnd - clampedStart))

        // Use contentsEnd to exclude the trailing newline from the window.
        let windowRange = NSRange(location: lineStart, length: contentsEnd - lineStart)
        return (ns.substring(with: windowRange), lineStart)
    }
}
