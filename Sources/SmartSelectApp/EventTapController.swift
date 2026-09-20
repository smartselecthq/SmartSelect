import AppKit
import CoreGraphics

/// Installs a passive, listen-only `CGEventTap` that fires a callback on every
/// double-click. It never swallows or mutates events — it only observes.
final class EventTapController {
    private var tap: CFMachPort?
    private var runLoopSource: CFRunLoopSource?
    private let onDoubleClick: () -> Void
    private(set) var isRunning = false

    /// Delay before reading the selection, to let the target app perform its own
    /// word-selection in response to the double-click first.
    private let settleDelay: TimeInterval = 0.04

    init(onDoubleClick: @escaping () -> Void) {
        self.onDoubleClick = onDoubleClick
    }

    func start() {
        guard !isRunning else { return }

        let callback: CGEventTapCallBack = { _, type, event, refcon in
            guard let refcon else { return Unmanaged.passUnretained(event) }
            let controller = Unmanaged<EventTapController>.fromOpaque(refcon).takeUnretainedValue()
            if type == .leftMouseDown, event.getIntegerValueField(.mouseEventClickState) == 2 {
                DispatchQueue.main.asyncAfter(deadline: .now() + controller.settleDelay) {
                    controller.onDoubleClick()
                }
            } else if type == .tapDisabledByTimeout || type == .tapDisabledByUserInput {
                controller.reEnable()
            }
            return Unmanaged.passUnretained(event)
        }

        let mask: CGEventMask = (1 << CGEventType.leftMouseDown.rawValue)
        guard let tap = CGEvent.tapCreate(
            tap: .cgSessionEventTap,
            place: .headInsertEventTap,
            options: .listenOnly,
            eventsOfInterest: mask,
            callback: callback,
            userInfo: Unmanaged.passUnretained(self).toOpaque()
        ) else {
            NSLog("SmartSelect: could not create event tap — is Accessibility access granted?")
            return
        }

        let source = CFMachPortCreateRunLoopSource(kCFAllocatorDefault, tap, 0)
        CFRunLoopAddSource(CFRunLoopGetCurrent(), source, .commonModes)
        CGEvent.tapEnable(tap: tap, enable: true)

        self.tap = tap
        self.runLoopSource = source
        isRunning = true
    }

    func stop() {
        guard isRunning, let tap, let runLoopSource else { return }
        CGEvent.tapEnable(tap: tap, enable: false)
        CFRunLoopRemoveSource(CFRunLoopGetCurrent(), runLoopSource, .commonModes)
        self.tap = nil
        self.runLoopSource = nil
        isRunning = false
    }

    /// The OS disables a tap that blocks too long; re-enable it if that happens.
    private func reEnable() {
        guard let tap else { return }
        CGEvent.tapEnable(tap: tap, enable: true)
    }
}
