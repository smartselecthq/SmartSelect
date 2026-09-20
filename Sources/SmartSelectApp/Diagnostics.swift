#if os(macOS)
import Foundation

/// Opt-in diagnostics. Off by default; enable by launching with SMARTSELECT_DEBUG=1
/// (or any non-empty value). When on, writes to a fixed file and mirrors to NSLog.
///
///     SMARTSELECT_DEBUG=1 open -W build/SmartSelect.app
///     tail -f /tmp/smartselect-debug.log
enum Log {
    private static let path = "/tmp/smartselect-debug.log"

    /// Enabled by env var `SMARTSELECT_DEBUG=1`, or by the presence of the sentinel file
    /// `/tmp/smartselect-debug` (handy when launched via `open`, which does not forward env).
    private static let enabled: Bool = {
        if let flag = ProcessInfo.processInfo.environment["SMARTSELECT_DEBUG"], !flag.isEmpty {
            return true
        }
        return FileManager.default.fileExists(atPath: "/tmp/smartselect-debug")
    }()

    static func d(_ message: @autoclosure () -> String) {
        guard enabled else { return }
        let text = message()
        NSLog("[SmartSelect] %@", text)
        let line = "\(timestamp()) \(text)\n"
        guard let data = line.data(using: .utf8) else { return }
        if let handle = FileHandle(forWritingAtPath: path) {
            handle.seekToEndOfFile()
            handle.write(data)
            try? handle.close()
        } else {
            try? data.write(to: URL(fileURLWithPath: path))
        }
    }

    /// Truncates the log; called once at launch so each run starts clean.
    static func reset() {
        guard enabled else { return }
        try? Data().write(to: URL(fileURLWithPath: path))
    }

    private static func timestamp() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm:ss.SSS"
        return formatter.string(from: Date())
    }
}
#endif
