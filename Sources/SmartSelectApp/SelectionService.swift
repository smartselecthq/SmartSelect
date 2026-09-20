#if os(macOS)
import Foundation
import SmartSelectCore

/// Orchestrates one expansion cycle: read the focused selection, run the pure engine,
/// and, if it widened, write the new selection back.
final class SelectionService {
    func expandCurrentSelection(using kinds: Set<EntityKind>, at point: CGPoint) {
        guard AccessibilityBridge.isTrusted else {
            Log.d("not trusted for Accessibility — grant access in System Settings")
            return
        }
        guard !kinds.isEmpty else {
            Log.d("no entity kinds enabled")
            return
        }
        let expander = SelectionExpander(enabledKinds: kinds)

        // Standard path: native text views and browser editable fields expose their text
        // through kAXValue + kAXSelectedTextRange.
        if let focused = AccessibilityBridge.focusedText() {
            if let result = expander.expandedSelectionInEnclosingLine(
                in: focused.value,
                around: focused.selection
            ) {
                let ok = AccessibilityBridge.setSelection(result.span, on: focused.element)
                Log.d("expanded to \(result.kind) '\(result.text)' set=\(ok)")
            } else {
                Log.d("no expansion for selection (\(focused.selection.location),\(focused.selection.length))")
            }
            return
        }

        // Fallback path: web-page text (Safari / WebKit content) exposes the selection as
        // an AXTextMarkerRange instead of a plain range.
        if AccessibilityBridge.expandWebSelection(using: expander, at: point) { return }

        Log.d("no readable text at focus (not a supported text element)")
    }
}
#endif
