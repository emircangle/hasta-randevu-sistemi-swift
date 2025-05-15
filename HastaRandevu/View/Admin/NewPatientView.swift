import SwiftUI

struct NewPatientView: View {
    @Environment(\.dismiss) var dismiss
    var onSuccess: (() -> Void)? = nil

    @State private var name = ""
    @State private var surname = ""
    @State private var email = ""
    @State private var password = ""
    @State private var phone = ""
    @State private var gender = "ERKEK"
    @State private var birthDate = Date()
    @State private var bloodType = "ARH_POS"
    @State private var chronicDiseases = ""

    @State private var showSuccess = false
    @State private var errorMessage: String?

    var body: some View {
        Form {
            Section(header: Text("Hasta Bilgileri")) {
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

                Picker("Kan Grubu", selection: $bloodType) {
                    ForEach(["ARH_POS", "ARH_NEG", "BRH_POS", "BRH_NEG", "ABRH_POS", "ABRH_NEG", "ORH_POS", "ORH_NEG"], id: \.self) {
                        Text($0)
                    }
                }

                TextField("Kronik Rahatsızlıklar", text: $chronicDiseases)
            }

            if let error = errorMessage {
                Text("❌ \(error)").foregroundColor(.red)
            }

            Button("✅ Hastayı Oluştur") {
                registerPatient()
            }
        }
        .navigationTitle("Yeni Hasta Ekle")
        .alert(isPresented: $showSuccess) {
            Alert(
                title: Text("Başarılı"),
                message: Text("Hasta başarıyla eklendi."),
                dismissButton: .default(Text("Tamam")) {
                    onSuccess?()
                    dismiss()
                }
            )
        }
    }

    private func registerPatient() {
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
            bloodType: bloodType,
            chronicDiseases: chronicDiseases,
            role: "HASTA",
            specialization: nil,
            clinic: nil
        )

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
