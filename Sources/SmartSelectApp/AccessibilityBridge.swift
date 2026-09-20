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
        let focusStatus = AXUIElementCopyAttributeValue(system, kAXFocusedUIElementAttribute as CFString, &focusedRef)
        guard focusStatus == .success, let focused = focusedRef else {
            Log.d("no focused element (AXError \(focusStatus.rawValue))")
            return nil
        }
        // AXUIElement is a CFType bridged to CFTypeRef; this cast is the documented idiom.
        let element = focused as! AXUIElement
        Log.d("focused role=\(copyStringAttribute(element, kAXRoleAttribute) ?? "?") " +
              "subrole=\(copyStringAttribute(element, kAXSubroleAttribute) ?? "-")")

        var valueRef: CFTypeRef?
        let valueStatus = AXUIElementCopyAttributeValue(element, kAXValueAttribute as CFString, &valueRef)
        guard valueStatus == .success, let value = valueRef as? String else {
            Log.d("no kAXValue string (AXError \(valueStatus.rawValue)) — app likely does not expose its text via Accessibility")
            return nil
        }

        var rangeRef: CFTypeRef?
        let rangeStatus = AXUIElementCopyAttributeValue(element, kAXSelectedTextRangeAttribute as CFString, &rangeRef)
        guard rangeStatus == .success, let rangeValue = rangeRef else {
            Log.d("no kAXSelectedTextRange (AXError \(rangeStatus.rawValue))")
            return nil
        }
        var cfRange = CFRange()
        guard AXValueGetValue(rangeValue as! AXValue, .cfRange, &cfRange) else {
            Log.d("kAXSelectedTextRange is not a CFRange")
            return nil
        }

        let span = TextSpan(location: cfRange.location, length: cfRange.length)
        Log.d("read value.len=\((value as NSString).length) selection=(\(span.location),\(span.length))")
        return FocusedText(element: element, value: value, selection: span)
    }

    private static func copyStringAttribute(_ element: AXUIElement, _ attribute: String) -> String? {
        var ref: CFTypeRef?
        guard AXUIElementCopyAttributeValue(element, attribute as CFString, &ref) == .success else { return nil }
        return ref as? String
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
