import SwiftUI

struct NewDoctorView: View {
    @Environment(\.dismiss) var dismiss
    var onSuccess: (() -> Void)? = nil

    @State private var name = ""
    @State private var surname = ""
    @State private var email = ""
    @State private var password = ""
    @State private var phone = ""
    @State private var gender = "ERKEK"
    @State private var birthDate = Date()
    @State private var specialization = ""

    @State private var showSuccess = false
    @State private var errorMessage: String?

    var body: some View {
        Form {
            Section(header: Text("Doktor Bilgileri")) {
                TextField("Ad", text: $name)
                TextField("Soyad", text: $surname)
                TextField("Email", text: $email)
                SecureField("Şifre", text: $password)
                TextField("Telefon", text: $phone)

                DatePicker("Doğum Tarihi", selection: $birthDate, displayedComponents: .date)

                Picker("Cinsiyet", selection: $gender) {
                    Text("Erkek").tag("ERKEK")
                    Text("Kadın").tag("KADIN")
                    Text("Belirtilmemiş").tag("BELIRTILMEMIS")
                }
                .pickerStyle(SegmentedPickerStyle())

                TextField("Uzmanlık", text: $specialization)
            }

            if let error = errorMessage {
                Text("❌ \(error)").foregroundColor(.red)
            }

            Button("✅ Doktoru Oluştur") {
                registerDoctor()
            }
        }
        .navigationTitle("Yeni Doktor Ekle")
        .alert(isPresented: $showSuccess) {
            Alert(
                title: Text("Başarılı"),
                message: Text("Doktor başarıyla eklendi."),
                dismissButton: .default(Text("Tamam")) {
                    onSuccess?()
                    dismiss()
                }
            )
        }
    }

    private func registerDoctor() {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"

        let request = RegisterRequest(
            name: name,
            surname: surname,
            email: email,
            password: password,
            phoneNumber: phone,
            gender: gender,
            birthDate: formatter.string(from: birthDate),
            bloodType: nil,
            chronicDiseases: "",
            role: "DOKTOR",
            specialization: specialization
        )
        // DEBUG: Gönderilen JSON
            if let jsonData = try? JSONEncoder().encode(request),
               let jsonString = String(data: jsonData, encoding: .utf8) {
                print("📦 [NewDoctorView] Gönderilen JSON:\n\(jsonString)")
            }

        UserService.shared.createUser(request) { result in
            DispatchQueue.main.async {
                switch result {
                case .success:
                    showSuccess = true
                case .failure(let error):
                    errorMessage = error.localizedDescription
                }
            }
        }

    }
}
