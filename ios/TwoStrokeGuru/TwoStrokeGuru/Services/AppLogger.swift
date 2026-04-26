import Foundation

final class AppLogger {
    static let shared = AppLogger()

    private let queue = DispatchQueue(label: "com.twostrokeguru.logger")
    private let fileManager = FileManager.default
    private let maxBytes = 1_000_000
    private let retainedCopies = 3
    private let dateFormatter: DateFormatter

    private var logDirectory: URL {
        let base = fileManager.urls(for: .applicationSupportDirectory, in: .userDomainMask)[0]
        return base.appendingPathComponent("Logs", isDirectory: true)
    }

    private var currentLogURL: URL {
        logDirectory.appendingPathComponent("app.log")
    }

    private init() {
        dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss.SSS zzz"
        dateFormatter.timeZone = TimeZone(identifier: "America/New_York")
    }

    func info(_ message: String, function: String = #function, line: Int = #line) {
        write(level: "INFO", message: message, function: function, line: line)
    }

    func error(_ message: String, function: String = #function, line: Int = #line) {
        write(level: "ERROR", message: message, function: function, line: line)
    }

    private func write(level: String, message: String, function: String, line: Int) {
        let timestamp = dateFormatter.string(from: Date())
        let entry = "\(timestamp) [\(level)] line=\(line) function=\(function) \(message)\n"

        print(entry, terminator: "")

        queue.async { [self] in
            do {
                try fileManager.createDirectory(at: logDirectory, withIntermediateDirectories: true)
                try rotateIfNeeded()

                if let data = entry.data(using: .utf8) {
                    if fileManager.fileExists(atPath: currentLogURL.path) {
                        let handle = try FileHandle(forWritingTo: currentLogURL)
                        try handle.seekToEnd()
                        try handle.write(contentsOf: data)
                        try handle.close()
                    } else {
                        try data.write(to: currentLogURL, options: .atomic)
                    }
                }
            } catch {
                print("\(timestamp) [ERROR] line=\(line) function=\(function) log_write_failed=\(error.localizedDescription)")
            }
        }
    }

    private func rotateIfNeeded() throws {
        guard let attributes = try? fileManager.attributesOfItem(atPath: currentLogURL.path),
              let size = attributes[.size] as? NSNumber,
              size.intValue >= maxBytes else {
            return
        }

        for index in stride(from: retainedCopies, through: 1, by: -1) {
            let source = rotatedLogURL(index: index)
            let destination = rotatedLogURL(index: index + 1)

            if fileManager.fileExists(atPath: destination.path) {
                try fileManager.removeItem(at: destination)
            }

            if fileManager.fileExists(atPath: source.path), index < retainedCopies {
                try fileManager.moveItem(at: source, to: destination)
            }
        }

        try fileManager.moveItem(at: currentLogURL, to: rotatedLogURL(index: 1))
    }

    private func rotatedLogURL(index: Int) -> URL {
        logDirectory.appendingPathComponent("app.log.\(index)")
    }
}
