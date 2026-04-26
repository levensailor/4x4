import Foundation

enum ContentConfiguration {
    static let supportedSchemaVersion = 1
    static let appVersion = "1.0.0"

    static var remoteBaseURL: URL {
        if let value = Bundle.main.object(forInfoDictionaryKey: "ContentBaseURL") as? String,
           let url = URL(string: value),
           !value.isEmpty {
            return url
        }

        return URL(string: AppBrand.contentBaseURL)!
    }
}
