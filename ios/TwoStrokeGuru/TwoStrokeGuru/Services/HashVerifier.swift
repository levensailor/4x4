import CryptoKit
import Foundation

struct HashVerifier {
    func verifySHA256(data: Data, expectedHex: String) -> Bool {
        let digest = SHA256.hash(data: data)
        let actualHex = digest.map { String(format: "%02x", $0) }.joined()
        return actualHex.lowercased() == expectedHex.lowercased()
    }
}
