import Foundation

enum ContentError: LocalizedError {
    case missingBundledContent
    case invalidRemoteURL
    case badHTTPStatus(Int)
    case unexpectedContentType(String?)
    case incompatibleSchema(Int)
    case unsupportedAppVersion(String)
    case hashMismatch

    var errorDescription: String? {
        switch self {
        case .missingBundledContent:
            return "Bundled seed content is missing."
        case .invalidRemoteURL:
            return "The remote content URL is invalid."
        case .badHTTPStatus(let status):
            return "The content server returned HTTP \(status)."
        case .unexpectedContentType(let contentType):
            return "The content server returned \(contentType ?? "an unknown content type") instead of JSON."
        case .incompatibleSchema(let version):
            return "Content schema \(version) is not supported by this app."
        case .unsupportedAppVersion(let minVersion):
            return "This content requires app version \(minVersion) or newer."
        case .hashMismatch:
            return "Downloaded content failed integrity verification."
        }
    }
}
