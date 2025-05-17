import Foundation

struct RegisterRequest: Encodable {
    let name: String
    let surname: String
    let email: String
    let password: String
    let phoneNumber: String
    let gender: String
    let birthDate: String
    let bloodType: String?
    let chronicDiseases: String
    let role: String?                 // 🔥 Optional olmalı
    let specialization: String?
    let clinic: ClinicReference?
}

struct ClinicReference: Codable {
    let id: Int
    let name: String?

    // ✅ Eski tek-parametreli kullanımlar için:
    init(id: Int, name: String? = nil) {
        self.id = id
        self.name = name
    }
}
