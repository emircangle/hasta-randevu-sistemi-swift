import SwiftUI

struct CreateComplaintView: View {
    @State private var subject = ""
    @State private var content = ""
    @State private var selectedClinic: Clinic?
    @State private var clinics: [Clinic] = []

    @State private var patientId: Int?
    @State private var errorMessage: String?
    @State private var successMessage: String?

    let konuListesi = [
        "Randevu Sorunu",
        "Klinikle İlgili Sorun",
        "Sistemsel Sorun",
        "Diğer"
    ]

    var showClinicSelect: Bool {
        subject == "Klinikle İlgili Sorun"
    }

    var placeholderText: String {
        switch subject {
        case "Randevu Sorunu":
            return "Randevu alamama, iptal, gecikme gibi detayları yazınız."
        case "Klinikle İlgili Sorun":
            return "Klinikte yaşadığınız yönlendirme/karışıklık gibi sorunu yazınız."
        case "Sistemsel Sorun":
            return "Sayfa açılmıyor, hata alıyorum gibi teknik sorunları yazınız."
        default:
            return "Yaşadığınız problemi detaylı bir şekilde açıklayın."
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("📢 Şikayet Oluştur")
                .font(.largeTitle)
                .bold()

            Picker("Konu", selection: $subject) {
                Text("-- Konu Seçiniz --").tag("")
                ForEach(konuListesi, id: \.self) { konu in
                    Text(konu).tag(konu)
                }
            }

            if showClinicSelect {
                Picker("Klinik Seçiniz", selection: $selectedClinic) {
                    Text("-- Seçiniz --").tag(nil as Clinic?)
                    ForEach(clinics) { clinic in
                        Text(clinic.name).tag(clinic as Clinic?)
                    }
                }
            }

            ZStack(alignment: .topLeading) {
                TextEditor(text: $content)
                    .frame(height: 120)
                    .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.gray.opacity(0.5)))

                if content.isEmpty {
                    Text(placeholderText)
                        .foregroundColor(.gray)
                        .padding(8)
                }
            }

            Button("Gönder") {
                submitComplaint()
            }
            .padding()
            .frame(maxWidth: .infinity)
            .background(Color.blue)
            .foregroundColor(.white)
            .cornerRadius(10)

            if let error = errorMessage {
                Text("❌ \(error)").foregroundColor(.red)
            }

            if let success = successMessage {
                Text("✅ \(success)").foregroundColor(.green)
            }

            Spacer()
        }
        .padding()
        .onAppear {
            loadCurrentUser()
            fetchClinics()
        }
        .overlay(alignment: .bottomTrailing) {
            AIChatView()
                .padding(.trailing, 16)
                .padding(.bottom, 32)
        }
    }

    private func loadCurrentUser() {
        if let email = TokenUtil.getEmailFromToken() {
            UserService.shared.fetchUserByEmail(email: email) { result in
                if case let .success(user) = result {
                    self.patientId = user.id
                }
            }
        }
    }

    private func fetchClinics() {
        ClinicService.shared.getAllClinics { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let data):
                    clinics = data
                case .failure(let error):
                    print("Klinikler alınamadı: \(error.localizedDescription)")
                }
            }
        }
    }

    private func submitComplaint() {
        guard let patientId, !subject.isEmpty, !content.isEmpty else {
            errorMessage = "Lütfen tüm alanları doldurun."
            return
        }

        let request = ComplaintRequest(
            subject: subject,
            content: content,
            user: PatientReference(id: patientId),
            clinic: selectedClinic != nil ? ClinicReference(id: selectedClinic!.id) : nil
        )

        ComplaintService.shared.createComplaint(request) { result in
            DispatchQueue.main.async {
                switch result {
                case .success:
                    successMessage = "Şikayetiniz gönderildi."
                    errorMessage = nil
                    subject = ""
                    content = ""
                    selectedClinic = nil
                case .failure(let error):
                    errorMessage = "Hata: \(error.localizedDescription)"
                    successMessage = nil
                }
            }
        }
    }
}
