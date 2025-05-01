import SwiftUI

struct MyComplaintsView: View {
    @State private var complaints: [Complaint] = []
    @State private var patientId: Int?
    @State private var isLoading = true
    @State private var errorMessage: String?

    var body: some View {
        NavigationView {
            VStack {
                if isLoading {
                    ProgressView("Yükleniyor...")
                } else if let error = errorMessage {
                    Text("❌ Hata: \(error)").foregroundColor(.red)
                } else if complaints.isEmpty {
                    Text("Hiç şikayet bulunamadı.")
                        .foregroundColor(.gray)
                } else {
                    List(complaints) { complaint in
                        VStack(alignment: .leading, spacing: 8) {
                            Text("📌 \(complaint.subject)").bold()
                            Text("📝 \(complaint.content)")
                            Text("🗓️ \(complaint.createdAt)").font(.caption)
                            Text("Durum: \(complaint.status)").foregroundColor(complaint.status == "COZULDU" ? .green : .orange)
                            if let note = complaint.adminNote {
                                Text("👨‍⚕️ Not: \(note)").italic()
                            }
                        }.padding(.vertical, 4)
                    }
                }
            }
            .navigationTitle("Şikayetlerim")
        }
        .onAppear(perform: loadComplaints)
        .overlay(alignment: .bottomTrailing) {
            AIChatView()
                .padding(.trailing, 16)
                .padding(.bottom, 32)
        }

    }

    private func loadComplaints() {
        guard let email = TokenUtil.getEmailFromToken() else { return }

        UserService.shared.fetchUserByEmail(email: email) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let user):
                    self.patientId = user.id
                    ComplaintService.shared.getComplaintsByPatientId(patientId: user.id) { response in
                        DispatchQueue.main.async {
                            isLoading = false
                            switch response {
                            case .success(let data):
                                complaints = data
                            case .failure(let error):
                                errorMessage = error.localizedDescription
                            }
                        }
                    }

                case .failure(let error):
                    self.errorMessage = error.localizedDescription
                    self.isLoading = false
                }
            }
        }
    }

}
