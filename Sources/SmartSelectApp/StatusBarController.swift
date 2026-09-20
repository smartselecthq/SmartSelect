#if os(macOS)
import AppKit
import SmartSelectCore

/// The menu-bar UI: an on/off toggle, per-entity-kind toggles, and Quit.
final class StatusBarController: NSObject {
    private let statusItem: NSStatusItem
    private let preferences: Preferences
    private let onEnabledChanged: (Bool) -> Void
    private let onQuit: () -> Void

    init(
        preferences: Preferences,
        onEnabledChanged: @escaping (Bool) -> Void,
        onQuit: @escaping () -> Void
    ) {
        self.preferences = preferences
        self.onEnabledChanged = onEnabledChanged
        self.onQuit = onQuit
        self.statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        super.init()
        configureButton()
        rebuildMenu()
    }

    private func configureButton() {
        guard let button = statusItem.button else { return }
        button.image = NSImage(systemSymbolName: "cursorarrow.rays", accessibilityDescription: "SmartSelect")
        button.image?.isTemplate = true
    }

    private func rebuildMenu() {
        let menu = NSMenu()

        let toggle = NSMenuItem(title: "SmartSelect Enabled", action: #selector(toggleEnabled), keyEquivalent: "")
        toggle.target = self
        toggle.state = preferences.isEnabled ? .on : .off
        menu.addItem(toggle)

        if !AccessibilityBridge.isTrusted {
            let warn = NSMenuItem(title: "⚠︎ Grant Accessibility Access…", action: #selector(openAccessibilitySettings), keyEquivalent: "")
            warn.target = self
            menu.addItem(warn)
        }

        menu.addItem(.separator())

        let header = NSMenuItem(title: "Snap selection to…", action: nil, keyEquivalent: "")
        header.isEnabled = false
        menu.addItem(header)

        let enabledKinds = preferences.enabledKinds
        for kind in EntityKind.allCases {
            let item = NSMenuItem(title: kind.displayName, action: #selector(toggleKind(_:)), keyEquivalent: "")
            item.target = self
            item.state = enabledKinds.contains(kind) ? .on : .off
            item.representedObject = kind.rawValue
            menu.addItem(item)
        }

        menu.addItem(.separator())

        let quit = NSMenuItem(title: "Quit SmartSelect", action: #selector(quit), keyEquivalent: "q")
        quit.target = self
        menu.addItem(quit)

        statusItem.menu = menu
    }

    @objc private func toggleEnabled() {
        preferences.isEnabled.toggle()
        onEnabledChanged(preferences.isEnabled)
        rebuildMenu()
    }

    @objc private func toggleKind(_ sender: NSMenuItem) {
        guard let raw = sender.representedObject as? String,
              let kind = EntityKind(rawValue: raw) else { return }
        preferences.setKind(kind, enabled: sender.state == .off)
        rebuildMenu()
    }

    @objc private func openAccessibilitySettings() {
        AccessibilityBridge.ensureTrusted(promptIfNeeded: true)
        let url = URL(string: "x-apple.systempreferences:com.apple.preference.security?Privacy_Accessibility")!
        NSWorkspace.shared.open(url)
    }

    @objc private func quit() {
        onQuit()
    }
}

#endif
