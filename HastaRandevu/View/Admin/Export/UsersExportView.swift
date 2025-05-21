import SwiftUI

struct UsersExportView: View {
    @State private var users: [User] = []
    @State private var message: String?

    var body: some View {
        VStack(spacing: 12) {
            Text("👤 Kullanıcı Verileri")
                .font(.title2).bold()

            if users.isEmpty {
                ProgressView("Veriler getiriliyor...")
            } else {
                ScrollView(.horizontal) {
                    Table(users) {
                        TableColumn("ID") { Text("\($0.id)") }
                        TableColumn("Ad") { Text($0.name) }
                        TableColumn("Soyad") { Text($0.surname) }
                        TableColumn("Email") { Text($0.email) }
                        TableColumn("Telefon") { Text($0.phoneNumber) }
                        TableColumn("Rol") { Text($0.role) }
                        TableColumn("Cinsiyet") { Text($0.gender) }
                        TableColumn("Kan Grubu") { Text($0.bloodType ?? "-") }
                        TableColumn("Kronik") { Text($0.chronicDiseases ?? "-") }
                        TableColumn("Uzmanlık") { Text($0.specialization ?? "-") }
                     //   TableColumn("Klinik") { Text($0.clinic?.name ?? "-") }
                    }
                    .frame(minHeight: 300)
                }

                Button("⬇️ CSV Olarak İndir") {
                    ExportService.shared.exportUsers { result in
                        switch result {
                        case .success(let file):
                            message = "📥 Dosya indirildi: \(file.lastPathComponent)"
                        case .failure:
                            message = "❌ İndirme başarısız"
                        }
                    }
                }
                .buttonStyle(.borderedProminent)

                if let message {
                    Text(message).font(.caption).foregroundColor(.gray)
                }
            }
        }
        .padding()
        .onAppear(perform: loadUsers)
        .navigationTitle("Kullanıcı İhracı")
    }

    private func loadUsers() {
        UserService.shared.getAllUsers { result in
            switch result {
            case .success(let data):
                self.users = data
            case .failure:
                self.message = "Kullanıcılar getirilemedi."
            }
        }
    }
}
