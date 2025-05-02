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

    static func getRoleFromToken() -> String? {
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
               let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any] {

                // Eğer authorities: [{authority: "ROLE_DOKTOR"}] gibi geldiyse:
                if let authorities = json["authorities"] as? [[String: Any]],
                   let role = authorities.first?["authority"] as? String {
                    return role
                }

                // Eğer role: "DOKTOR" gibi geldiyse:
                if let role = json["role"] as? String {
                    return role
                }
            }
        }

        return nil
    }
}

