import Foundation

struct BundledContentProvider {
    func loadBundle() throws -> ContentBundle {
        guard let url = Bundle.main.url(forResource: "content", withExtension: "json") else {
            throw ContentError.missingBundledContent
        }

        let data = try Data(contentsOf: url)
        return try JSONDecoder().decode(ContentBundle.self, from: data)
    }
}
