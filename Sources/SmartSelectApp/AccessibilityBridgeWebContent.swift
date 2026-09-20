#if os(macOS)
import ApplicationServices
import SmartSelectCore

/// Web-content selection support.
///
/// Browsers (Safari, and WebKit content) do not expose page text through the simple
/// `kAXValue` + `kAXSelectedTextRange` attributes native text views use. Instead the
/// selection is an `AXTextMarkerRange`, navigated with WebKit's text-marker parameterized
/// attributes. There is no call to read a range's endpoints, so this path anchors off the
/// double-click *position*: it resolves a marker at the click, gathers a text window around
/// it, expands within that window, and walks markers out from the click to reselect.
extension AccessibilityBridge {
    private enum AX {
        static let selectedMarkerRange = "AXSelectedTextMarkerRange"
        static let markerForPosition = "AXTextMarkerForPosition"
        static let stringForRange = "AXStringForTextMarkerRange"
        static let nextMarker = "AXNextTextMarkerForTextMarker"
        static let prevMarker = "AXPreviousTextMarkerForTextMarker"
        static let rangeForMarkers = "AXTextMarkerRangeForUnorderedTextMarkers"
    }

    /// Characters of context to gather on each side of the click.
    private static let contextRadius = 60

    /// Attempts to expand the web-content selection around the double-click at `point`.
    static func expandWebSelection(using expander: SelectionExpander, at point: CGPoint) -> Bool {
        guard isTrusted else { return false }
        let system = AXUIElementCreateSystemWide()
        guard let focused = attr(system, kAXFocusedUIElementAttribute) else { return false }
        let focusedElement = focused as! AXUIElement

        guard let element = markerCapableElement(from: focusedElement) else {
            Log.d("web: no marker-capable element in focus chain")
            return false
        }

        var pt = point
        guard let axPoint = AXValueCreate(.cgPoint, &pt) else { return false }
        guard let clickMarker = param(element, AX.markerForPosition, axPoint) else {
            Log.d("web: no marker for click position")
            return false
        }

        // Gather a window of context around the click by walking markers out from it.
        let leftMarker = walkUpTo(element, from: clickMarker, attribute: AX.prevMarker, steps: contextRadius)
        let rightMarker = walkUpTo(element, from: clickMarker, attribute: AX.nextMarker, steps: contextRadius)

        guard let contextRange = markerRange(element, leftMarker, rightMarker),
              let context = param(element, AX.stringForRange, contextRange) as? String,
              let preRange = markerRange(element, leftMarker, clickMarker),
              let pre = param(element, AX.stringForRange, preRange) as? String else {
            Log.d("web: could not read context around click")
            return false
        }

        // The click's offset within the context is exactly the text to its left.
        let offset = (pre as NSString).length
        Log.d("web: context='\(context)' clickOffset=\(offset)")

        guard let result = expander.expandedSelection(
            in: context,
            around: TextSpan(location: offset, length: 0)
        ) else {
            Log.d("web: no entity around click")
            return false
        }

        // Walk markers out from the click to the entity edges, then reselect.
        let leftSteps = offset - result.span.location
        let rightSteps = result.span.upperBound - offset
        guard leftSteps >= 0, rightSteps >= 0,
              let entityStart = walkExact(element, from: clickMarker, attribute: AX.prevMarker, steps: leftSteps),
              let entityEnd = walkExact(element, from: clickMarker, attribute: AX.nextMarker, steps: rightSteps),
              let newRange = markerRange(element, entityStart, entityEnd) else {
            Log.d("web: could not build entity marker range")
            return false
        }

        let ok = AXUIElementSetAttributeValue(element, AX.selectedMarkerRange as CFString, newRange) == .success
        Log.d("web: expanded to \(result.kind) '\(result.text)' set=\(ok)")
        return ok
    }

    // MARK: - Helpers

    private static func markerCapableElement(from start: AXUIElement) -> AXUIElement? {
        var element: AXUIElement? = start
        var hops = 0
        while let current = element, hops < 6 {
            if attr(current, AX.selectedMarkerRange as CFString) != nil {
                return current
            }
            element = attr(current, kAXParentAttribute).map { $0 as! AXUIElement }
            hops += 1
        }
        return nil
    }

    private static func attr(_ element: AXUIElement, _ attribute: CFString) -> CFTypeRef? {
        var result: CFTypeRef?
        return AXUIElementCopyAttributeValue(element, attribute, &result) == .success ? result : nil
    }

    private static func attr(_ element: AXUIElement, _ attribute: String) -> CFTypeRef? {
        attr(element, attribute as CFString)
    }

    private static func param(_ element: AXUIElement, _ attribute: String, _ parameter: CFTypeRef) -> CFTypeRef? {
        var result: CFTypeRef?
        return AXUIElementCopyParameterizedAttributeValue(element, attribute as CFString, parameter, &result) == .success
            ? result : nil
    }

    private static func markerRange(_ element: AXUIElement, _ a: CFTypeRef, _ b: CFTypeRef) -> CFTypeRef? {
        param(element, AX.rangeForMarkers, [a, b] as CFArray)
    }

    /// Moves up to `steps` in one direction, returning the furthest reachable marker
    /// (stops early and keeps the last good marker at a document boundary).
    private static func walkUpTo(_ element: AXUIElement, from marker: CFTypeRef, attribute: String, steps: Int) -> CFTypeRef {
        var current = marker
        for _ in 0..<steps {
            guard let next = param(element, attribute, current) else { break }
            current = next
        }
        return current
    }

    /// Moves exactly `steps`; returns nil if a boundary is hit first.
    private static func walkExact(_ element: AXUIElement, from marker: CFTypeRef, attribute: String, steps: Int) -> CFTypeRef? {
        var current = marker
        for _ in 0..<steps {
            guard let next = param(element, attribute, current) else { return nil }
            current = next
        }
        return current
    }
}
#endif
