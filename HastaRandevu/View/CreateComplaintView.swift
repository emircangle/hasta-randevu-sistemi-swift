import SwiftUI

struct CreateComplaintView: View {
    @State private var title = ""
    @State private var description = ""
    @State private var errorMessage: String?
    @State private var successMessage: String?
    @State private var patientId: Int?

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("📢 Şikayet Oluştur")
                .font(.largeTitle)
                .bold()

            TextField("Başlık", text: $title)
                .textFieldStyle(RoundedBorderTextFieldStyle())

            TextEditor(text: $description)
                .frame(height: 120)
                .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.gray.opacity(0.5)))

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
        .onAppear(perform: loadCurrentUser)
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

    private func submitComplaint() {
        guard let patientId = patientId, !title.isEmpty, !description.isEmpty else {
            errorMessage = "Lütfen tüm alanları doldurun."
            return
        }

        let request = ComplaintRequest(
            subject: title,
            content: description.isEmpty ? "Boş açıklama" : description,
            user: PatientReference(id: patientId)
        )

        print("🚀 Giden Şikayet:", request)


        ComplaintService.shared.createComplaint(request) { result in
            DispatchQueue.main.async {
                switch result {
                case .success:
                    successMessage = "Şikayetiniz gönderildi."
                    errorMessage = nil
                    title = ""
                    description = ""
                case .failure(let error):
                    errorMessage = "Hata: \(error.localizedDescription)"
                    successMessage = nil
                }
            }
        }
    }
}
