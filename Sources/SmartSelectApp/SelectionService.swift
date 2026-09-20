#if os(macOS)
import Foundation
import SmartSelectCore

/// Orchestrates one expansion cycle: read the focused selection, run the pure engine,
/// and, if it widened, write the new selection back.
final class SelectionService {
    func expandCurrentSelection(using kinds: Set<EntityKind>) {
        guard AccessibilityBridge.isTrusted else {
            Log.d("not trusted for Accessibility — grant access in System Settings")
            return
        }
        guard !kinds.isEmpty else {
            Log.d("no entity kinds enabled")
            return
        }
        guard let focused = AccessibilityBridge.focusedText() else { return }

        let expander = SelectionExpander(enabledKinds: kinds)
        guard let result = expander.expandedSelectionInEnclosingLine(
            in: focused.value,
            around: focused.selection
        ) else {
            Log.d("no expansion for selection (\(focused.selection.location),\(focused.selection.length))")
            return
        }

        let ok = AccessibilityBridge.setSelection(result.span, on: focused.element)
        Log.d("expanded to \(result.kind) '\(result.text)' set=\(ok)")
    }
}

#endif
