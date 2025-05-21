import SwiftUI

struct ComplaintsExportView: View {
    @State private var complaints: [Complaint] = []
    @State private var message: String?

    var body: some View {
        VStack(spacing: 12) {
            Text("📋 Şikayet Verileri").font(.title2).bold()

            if complaints.isEmpty {
                ProgressView("Veriler getiriliyor...")
            } else {
                ScrollView(.horizontal) {
                    Table(complaints) {
                        TableColumn("ID") { Text("\($0.id)") }
                        TableColumn("Konu") { Text($0.subject) }
                        TableColumn("İçerik") { Text($0.content) }
                        TableColumn("Durum") { Text($0.status) }
                        TableColumn("Tarih") { Text($0.createdAt) }
                        TableColumn("Yönetici Notu") { Text($0.adminNote ?? "-") }
                        TableColumn("Klinik") { Text($0.clinic?.name ?? "-") }
                        TableColumn("Kullanıcı") {
                            Text("\($0.user.name ?? "-") \($0.user.surname ?? "")")
                        }
                    }
                }

                Button("⬇️ CSV Olarak İndir") {
                    ExportService.shared.exportComplaints { result in
                        switch result {
                        case .success(let file): message = "📥 \(file.lastPathComponent) indirildi."
                        case .failure: message = "❌ İndirme başarısız."
                        }
                    }
                }
                .buttonStyle(.borderedProminent)

                if let message { Text(message).font(.caption).foregroundColor(.gray) }
            }
        }
        .padding()
        .onAppear(perform: loadComplaints)
        .navigationTitle("Şikayet İhracı")
    }

    private func loadComplaints() {
        ComplaintService.shared.getAllComplaints { result in
            if case let .success(list) = result {
                complaints = list
            } else {
                message = "Veriler getirilemedi."
            }
        }
    }
}
