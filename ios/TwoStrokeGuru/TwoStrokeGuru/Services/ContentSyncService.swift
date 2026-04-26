import Foundation

struct ContentSyncService {
    private let session: URLSession
    private let fileStore: ContentFileStore
    private let hashVerifier: HashVerifier

    init(
        session: URLSession = .shared,
        fileStore: ContentFileStore = ContentFileStore(),
        hashVerifier: HashVerifier = HashVerifier()
    ) {
        self.session = session
        self.fileStore = fileStore
        self.hashVerifier = hashVerifier
    }

    func fetchLatestContent(currentVersion: String?) async throws -> ContentBundle? {
        let manifestURL = ContentConfiguration.remoteBaseURL.appendingPathComponent("content/manifest.json")
        AppLogger.shared.info("Fetching content manifest from \(manifestURL.absoluteString).")
        let manifestData = try await fetchJSONData(from: manifestURL)
        let manifest = try JSONDecoder().decode(ContentManifest.self, from: manifestData)

        guard manifest.schemaVersion <= ContentConfiguration.supportedSchemaVersion else {
            throw ContentError.incompatibleSchema(manifest.schemaVersion)
        }

        guard manifest.minAppVersion <= ContentConfiguration.appVersion else {
            throw ContentError.unsupportedAppVersion(manifest.minAppVersion)
        }

        guard manifest.contentVersion != currentVersion else {
            AppLogger.shared.info("Manifest version \(manifest.contentVersion) matches current content.")
            return nil
        }

        guard let bundleURL = URL(string: manifest.bundle.url, relativeTo: ContentConfiguration.remoteBaseURL) else {
            throw ContentError.invalidRemoteURL
        }

        AppLogger.shared.info("Fetching content bundle from \(bundleURL.absoluteString).")
        let contentData = try await fetchJSONData(from: bundleURL)
        guard hashVerifier.verifySHA256(data: contentData, expectedHex: manifest.bundle.sha256) else {
            throw ContentError.hashMismatch
        }

        let decoded = try JSONDecoder().decode(ContentBundle.self, from: contentData)
        try fileStore.saveVerifiedContent(contentData)
        return decoded
    }

    private func fetchJSONData(from url: URL) async throws -> Data {
        let (data, response) = try await session.data(from: url)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw ContentError.invalidRemoteURL
        }

        guard (200..<300).contains(httpResponse.statusCode) else {
            throw ContentError.badHTTPStatus(httpResponse.statusCode)
        }

        let contentType = httpResponse.value(forHTTPHeaderField: "Content-Type")
        if let contentType, !contentType.localizedCaseInsensitiveContains("json") {
            throw ContentError.unexpectedContentType(contentType)
        }

        return data
    }
}
