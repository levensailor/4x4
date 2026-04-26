import Foundation

struct ContentFileStore {
    private let fileManager = FileManager.default

    private var cacheDirectory: URL {
        let base = fileManager.urls(for: .applicationSupportDirectory, in: .userDomainMask)[0]
        return base.appendingPathComponent("ContentCache/current", isDirectory: true)
    }

    private var cachedContentURL: URL {
        cacheDirectory.appendingPathComponent("content.json")
    }

    func loadCachedBundle() throws -> ContentBundle? {
        guard fileManager.fileExists(atPath: cachedContentURL.path) else {
            return nil
        }

        let data = try Data(contentsOf: cachedContentURL)
        return try JSONDecoder().decode(ContentBundle.self, from: data)
    }

    func saveVerifiedContent(_ data: Data) throws {
        let temporaryDirectory = cacheDirectory
            .deletingLastPathComponent()
            .appendingPathComponent("next-\(UUID().uuidString)", isDirectory: true)
        let temporaryContentURL = temporaryDirectory.appendingPathComponent("content.json")

        try fileManager.createDirectory(at: temporaryDirectory, withIntermediateDirectories: true)
        try data.write(to: temporaryContentURL, options: .atomic)

        if fileManager.fileExists(atPath: cacheDirectory.path) {
            try fileManager.removeItem(at: cacheDirectory)
        }

        try fileManager.moveItem(at: temporaryDirectory, to: cacheDirectory)
    }
}
