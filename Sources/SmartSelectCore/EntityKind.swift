import Foundation

/// The categories of "meaningful entity" SmartSelect knows how to snap a selection to.
///
/// The order of `allCases` is also the **default detection priority** used by
/// ``SelectionExpander`` — earlier cases win when two detectors would match overlapping
/// text (e.g. an IPv4 address must beat the generic number detector).
public enum EntityKind: String, CaseIterable, Sendable, Codable {
    case email
    case url
    case ipAddress
    case dateTime
    case hexColor
    case filePath
    case handle
    case number

    /// Human-readable label for menus and preferences.
    public var displayName: String {
        switch self {
        case .email: return "Email addresses"
        case .url: return "URLs"
        case .ipAddress: return "IP addresses"
        case .dateTime: return "Dates & times"
        case .hexColor: return "Hex colors"
        case .filePath: return "File paths"
        case .handle: return "@handles & #tags"
        case .number: return "Numbers & amounts"
        }
    }

    /// A short example shown next to the label in the preferences UI.
    public var example: String {
        switch self {
        case .email: return "jane.doe@acme.co"
        case .url: return "https://example.com/pricing"
        case .ipAddress: return "192.168.1.1"
        case .dateTime: return "2026-09-19"
        case .hexColor: return "#1E90FF"
        case .filePath: return "~/Projects/app/main.swift"
        case .handle: return "@typesafeai"
        case .number: return "$1,299.00"
        }
    }
}
