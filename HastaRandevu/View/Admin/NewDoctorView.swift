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
    @State private var clinics: [Clinic] = []
    @State private var selectedClinicId: Int? = nil

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

                Picker("Klinik Seçin", selection: $selectedClinicId) {
                    Text("-- Seçin --").tag(nil as Int?)
                    ForEach(clinics, id: \.id) { clinic in
                        Text(clinic.name).tag(clinic.id as Int?)
                    }
                }
            }

            if let error = errorMessage {
                Text("❌ \(error)").foregroundColor(.red)
            }

            Button("✅ Doktoru Oluştur") {
                registerDoctor()
            }
            .disabled(selectedClinicId == nil || specialization.isEmpty || name.isEmpty || surname.isEmpty || email.isEmpty || password.isEmpty || phone.isEmpty)
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
        .onAppear(perform: fetchClinics)
    }

    private func fetchClinics() {
        ClinicService.shared.getAllClinics { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let data):
                    clinics = data.filter { $0.isActive }
                case .failure(let err):
                    errorMessage = "Klinikler alınamadı: \(err.localizedDescription)"
                }
            }
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
            specialization: specialization,
            clinic: selectedClinicId.map { ClinicReference(id: $0) }
        )

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
