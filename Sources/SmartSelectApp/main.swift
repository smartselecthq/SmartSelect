#if os(macOS)
import AppKit

// SmartSelect runs as a menu-bar "accessory" agent — no Dock icon, no main window.
let application = NSApplication.shared
let delegate = AppDelegate()
application.delegate = delegate
application.setActivationPolicy(.accessory)
application.run()

#endif
