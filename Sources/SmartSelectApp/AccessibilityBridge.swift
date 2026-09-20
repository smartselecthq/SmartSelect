#if os(macOS)
import AppKit
import ApplicationServices
import SmartSelectCore

/// Thin wrapper over the macOS Accessibility (AX) API for reading and writing the
/// selection of whatever text element currently has focus.
enum AccessibilityBridge {
    /// Whether this process is trusted for Accessibility control.
    static var isTrusted: Bool { AXIsProcessTrusted() }

    /// Checks trust, optionally showing the system prompt that deep-links to
    /// System Settings → Privacy & Security → Accessibility.
    @discardableResult
    static func ensureTrusted(promptIfNeeded: Bool) -> Bool {
        let key = kAXTrustedCheckOptionPrompt.takeUnretainedValue() as String
        let options = [key: promptIfNeeded] as CFDictionary
        return AXIsProcessTrustedWithOptions(options)
    }

    /// The focused element together with its full text value and current selection.
    struct FocusedText {
        let element: AXUIElement
        let value: String
        let selection: TextSpan
    }

    static func focusedText() -> FocusedText? {
        let system = AXUIElementCreateSystemWide()

        var focusedRef: CFTypeRef?
        guard AXUIElementCopyAttributeValue(system, kAXFocusedUIElementAttribute as CFString, &focusedRef) == .success,
              let focused = focusedRef else { return nil }
        // AXUIElement is a CFType bridged to CFTypeRef; this cast is the documented idiom.
        let element = focused as! AXUIElement

        var valueRef: CFTypeRef?
        guard AXUIElementCopyAttributeValue(element, kAXValueAttribute as CFString, &valueRef) == .success,
              let value = valueRef as? String else { return nil }

        var rangeRef: CFTypeRef?
        guard AXUIElementCopyAttributeValue(element, kAXSelectedTextRangeAttribute as CFString, &rangeRef) == .success,
              let rangeValue = rangeRef else { return nil }
        var cfRange = CFRange()
        guard AXValueGetValue(rangeValue as! AXValue, .cfRange, &cfRange) else { return nil }

        let span = TextSpan(location: cfRange.location, length: cfRange.length)
        return FocusedText(element: element, value: value, selection: span)
    }

    /// Applies a new selected range to the given element.
    @discardableResult
    static func setSelection(_ span: TextSpan, on element: AXUIElement) -> Bool {
        var cfRange = CFRange(location: span.location, length: span.length)
        guard let axValue = AXValueCreate(.cfRange, &cfRange) else { return false }
        return AXUIElementSetAttributeValue(element, kAXSelectedTextRangeAttribute as CFString, axValue) == .success
    }
}

#endif
