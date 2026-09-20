import Foundation

/// The result of expanding a selection to an enclosing entity.
public struct ExpansionResult: Equatable, Sendable {
    public let kind: EntityKind
    public let span: TextSpan
    public let text: String

    public init(kind: EntityKind, span: TextSpan, text: String) {
        self.kind = kind
        self.span = span
        self.text = text
    }
}

/// The heart of SmartSelect: given some text and the range the OS just selected on a
/// double-click, find the "meaningful entity" that encloses it and return the wider range.
///
/// The engine is pure and deterministic — no I/O, no platform APIs — which is what lets it
/// be exhaustively unit-tested and reused on any platform.
public struct SelectionExpander: Sendable {
    public let detectors: [EntityDetector]

    /// Builds an expander from an explicit detector chain (priority = array order).
    public init(detectors: [EntityDetector]) {
        self.detectors = detectors
    }

    /// Builds an expander for a set of enabled kinds, preserving ``EntityKind`` priority order.
    public init(enabledKinds: Set<EntityKind> = Set(EntityKind.allCases)) {
        self.detectors = EntityKind.allCases
            .filter(enabledKinds.contains)
            .map(SelectionExpander.detector(for:))
    }

    /// The built-in detector for a kind.
    public static func detector(for kind: EntityKind) -> EntityDetector {
        switch kind {
        case .email: return RegexEntityDetector(kind: .email, pattern: EntityPatterns.email)
        case .url: return RegexEntityDetector(kind: .url, pattern: EntityPatterns.url)
        case .ipAddress: return RegexEntityDetector(kind: .ipAddress, pattern: EntityPatterns.ipAddress)
        case .dateTime: return RegexEntityDetector(kind: .dateTime, pattern: EntityPatterns.dateTime)
        case .hexColor: return RegexEntityDetector(kind: .hexColor, pattern: EntityPatterns.hexColor)
        case .filePath: return RegexEntityDetector(kind: .filePath, pattern: EntityPatterns.filePath)
        case .handle: return RegexEntityDetector(kind: .handle, pattern: EntityPatterns.handle)
        case .number: return RegexEntityDetector(kind: .number, pattern: EntityPatterns.number)
        }
    }

    /// The default expander: every kind, in priority order.
    public static let `default` = SelectionExpander()

    /// Expand `current` to an enclosing entity within `text`.
    ///
    /// Returns `nil` when the selection is already the whole entity, when no entity
    /// encloses it, or when `current` is out of bounds.
    public func expandedSelection(in text: String, around current: TextSpan) -> ExpansionResult? {
        let ns = text as NSString
        let hit = current.nsRange
        guard hit.location != NSNotFound,
              hit.location >= 0,
              hit.upperBound <= ns.length else { return nil }

        for detector in detectors {
            guard let range = detector.match(in: text, containing: hit) else { continue }
            let span = TextSpan(range)
            // Only act when it genuinely widens the current selection.
            guard span != current, span.contains(current), span.length > current.length else { continue }
            return ExpansionResult(kind: detector.kind, span: span, text: ns.substring(with: range))
        }
        return nil
    }

    /// Convenience that first narrows `text` to the line enclosing `current`, runs the
    /// expansion on that window, and maps the result back to `text` coordinates.
    ///
    /// This is what the app uses: it keeps detection fast on large documents and avoids
    /// matching an entity on a different line than the one the user clicked.
    public func expandedSelectionInEnclosingLine(in text: String, around current: TextSpan) -> ExpansionResult? {
        let (window, offset) = TextWindow.enclosingLine(in: text, around: current)
        let localCurrent = TextSpan(location: current.location - offset, length: current.length)
        guard let local = expandedSelection(in: window, around: localCurrent) else { return nil }
        let globalSpan = TextSpan(location: local.span.location + offset, length: local.span.length)
        return ExpansionResult(kind: local.kind, span: globalSpan, text: local.text)
    }
}
