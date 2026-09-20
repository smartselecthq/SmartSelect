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
        Log.reset()
        let trusted = AccessibilityBridge.ensureTrusted(promptIfNeeded: true)
        Log.d("launched. accessibility trusted=\(trusted)")

        let tap = EventTapController { [weak self] point in
            self?.handleDoubleClick(at: point)
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

    private func handleDoubleClick(at point: CGPoint) {
        guard Preferences.shared.isEnabled else { return }
        selection.expandCurrentSelection(using: Preferences.shared.enabledKinds, at: point)
    }
}

#endif
