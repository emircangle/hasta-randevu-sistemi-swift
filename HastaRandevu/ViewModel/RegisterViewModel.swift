import Foundation

class RegisterViewModel: ObservableObject {
    @Published var isRegistered = false
    @Published var errorMessage: String?

    func registerUser(
        name: String,
        surname: String,
        email: String,
        password: String,
        phone: String,
        gender: String,
        birthDate: Date,
        bloodGroup: String,
        chronicDiseases: String
    ) {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withFullDate]

        let request = RegisterRequest(
            name: name,
            surname: surname,
            email: email,
            password: password,
            phoneNumber: phone,
            gender: gender.uppercased(), // enum uyumu için
            birthDate: formatter.string(from: birthDate),
            bloodType: bloodGroup.uppercased(), // enum uyumu için
            chronicDiseases: chronicDiseases,
            role: nil,                    // hasta olduğu için otomatik atanacak
            specialization: nil
        )

        print("📤 Gönderilen kayıt isteği: \(request)")

        AuthService.shared.registerUser(request: request) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let message):
                    print("✅ Kayıt başarılı: \(message)")
                    self.isRegistered = true
                case .failure(let error):
                    print("❌ Hata: \(error.localizedDescription)")
                    self.errorMessage = error.localizedDescription
                    self.isRegistered = false
                }
            }
        }
    }
}

