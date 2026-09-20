import Foundation
import SmartSelectCore

/// Orchestrates one expansion cycle: read the focused selection, run the pure engine,
/// and, if it widened, write the new selection back.
final class SelectionService {
    func expandCurrentSelection(using kinds: Set<EntityKind>) {
        guard AccessibilityBridge.isTrusted else { return }
        guard !kinds.isEmpty else { return }
        guard let focused = AccessibilityBridge.focusedText() else { return }

        let expander = SelectionExpander(enabledKinds: kinds)
        guard let result = expander.expandedSelectionInEnclosingLine(
            in: focused.value,
            around: focused.selection
        ) else { return }

        AccessibilityBridge.setSelection(result.span, on: focused.element)
    }
}
