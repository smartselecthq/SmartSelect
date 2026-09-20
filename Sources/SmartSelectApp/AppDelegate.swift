#if os(macOS)
import AppKit
import SmartSelectCore

final class AppDelegate: NSObject, NSApplicationDelegate {
    private var statusBar: StatusBarController?
    private var eventTap: EventTapController?
    private let selection = SelectionService()

    func applicationDidFinishLaunching(_ notification: Notification) {
        // Prompt for Accessibility access on first launch; it is required for both the
        // event tap and reading/writing the focused element's selection.
        AccessibilityBridge.ensureTrusted(promptIfNeeded: true)

        let tap = EventTapController { [weak self] in
            self?.handleDoubleClick()
        }
        eventTap = tap

        statusBar = StatusBarController(preferences: .shared) { enabled in
            enabled ? tap.start() : tap.stop()
        } onQuit: {
            NSApp.terminate(nil)
        }

        if Preferences.shared.isEnabled {
            tap.start()
        }
    }

    private func handleDoubleClick() {
        guard Preferences.shared.isEnabled else { return }
        selection.expandCurrentSelection(using: Preferences.shared.enabledKinds)
    }
}

#endif
