import Foundation

@MainActor
final class ContentRepository: ObservableObject {
    @Published private(set) var bundle: ContentBundle?
    @Published private(set) var statusMessage = "Loading content..."
    @Published private(set) var isRefreshing = false

    private let bundledProvider = BundledContentProvider()
    private let fileStore = ContentFileStore()
    private let syncService = ContentSyncService()

    func load() async {
        if bundle != nil {
            return
        }

        AppLogger.shared.info("Starting content load.")

        do {
            if let cached = try fileStore.loadCachedBundle() {
                bundle = cached
                statusMessage = "Offline content loaded."
                AppLogger.shared.info("Loaded cached content version \(cached.contentVersion).")
            } else {
                bundle = try bundledProvider.loadBundle()
                statusMessage = "Bundled content loaded."
                AppLogger.shared.info("Loaded bundled content version \(bundle?.contentVersion ?? "unknown").")
            }
        } catch {
            statusMessage = error.localizedDescription
            AppLogger.shared.error("Content load failed: \(error.localizedDescription).")
        }

        await refresh()
    }

    func refresh() async {
        guard !isRefreshing else {
            return
        }

        isRefreshing = true
        defer { isRefreshing = false }

        do {
            if let latest = try await syncService.fetchLatestContent(currentVersion: bundle?.contentVersion) {
                bundle = latest
                statusMessage = "Updated \(latest.generatedAt)."
                AppLogger.shared.info("Updated content to version \(latest.contentVersion).")
            } else if bundle != nil {
                statusMessage = "Content is up to date."
                AppLogger.shared.info("Remote content is up to date.")
            }
        } catch {
            if bundle == nil {
                statusMessage = error.localizedDescription
            } else {
                statusMessage = "Using offline content."
            }
            AppLogger.shared.error("Content refresh failed: \(error.localizedDescription).")
        }
    }
}
