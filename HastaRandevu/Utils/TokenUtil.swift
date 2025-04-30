import Foundation

struct TokenUtil {
    static func getEmailFromToken() -> String? {
        guard let token = UserDefaults.standard.string(forKey: "jwtToken") else {
            return nil
        }

        let parts = token.split(separator: ".")
        if parts.count > 1 {
            var payload = String(parts[1])
            while payload.count % 4 != 0 {
                payload += "="
            }

            if let data = Data(base64Encoded: payload),
               let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
               let email = json["sub"] as? String {
                return email
            }
        }
        return nil
    }
}
