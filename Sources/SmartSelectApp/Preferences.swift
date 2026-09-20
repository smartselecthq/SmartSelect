#if os(macOS)
import Foundation
import SmartSelectCore

/// User-facing settings, backed by `UserDefaults`.
final class Preferences {
    static let shared = Preferences()

    private let defaults: UserDefaults

    private enum Key {
        static let enabled = "com.smartselect.enabled"
        static let disabledKinds = "com.smartselect.disabledKinds"
    }

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
        self.defaults.register(defaults: [Key.enabled: true])
    }

    var isEnabled: Bool {
        get { defaults.bool(forKey: Key.enabled) }
        set { defaults.set(newValue, forKey: Key.enabled) }
    }

    /// Kinds currently active (all kinds minus the explicitly disabled ones).
    var enabledKinds: Set<EntityKind> {
        let disabled = storedDisabledKinds
        return Set(EntityKind.allCases).subtracting(disabled)
    }

    func setKind(_ kind: EntityKind, enabled: Bool) {
        var disabled = storedDisabledKinds
        if enabled {
            disabled.remove(kind)
        } else {
            disabled.insert(kind)
        }
        defaults.set(disabled.map(\.rawValue), forKey: Key.disabledKinds)
    }

    private var storedDisabledKinds: Set<EntityKind> {
        let raw = defaults.array(forKey: Key.disabledKinds) as? [String] ?? []
        return Set(raw.compactMap(EntityKind.init(rawValue:)))
    }
}

#endif
