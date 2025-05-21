import SwiftUI

struct PatientHistoriesExportView: View {
    @State private var histories: [PatientHistory] = []
    @State private var message: String?

    var body: some View {
        VStack(spacing: 12) {
            Text("📚 Hasta Geçmişi Verileri").font(.title2).bold()

            if histories.isEmpty {
                ProgressView("Veriler getiriliyor...")
            } else {
                ScrollView(.horizontal) {
                    Table(histories) {
                        TableColumn("ID") { Text("\($0.id)") }
                        TableColumn("Hasta") { Text("\($0.patient.name ?? "-") \($0.patient.surname ?? "")")}
                        TableColumn("Doktor") { Text("\($0.doctor?.name ?? "-") \($0.doctor?.surname ?? "")") }
                        TableColumn("Teşhis") { Text($0.diagnosis) }
                        TableColumn("Tedavi") { Text($0.treatment) }
                        TableColumn("Notlar") { Text($0.notes ?? "-") }
                        TableColumn("Tarih") { Text($0.date) }
                    }
                }

                Button("⬇️ CSV Olarak İndir") {
                    ExportService.shared.exportPatientHistories { result in
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
        .onAppear(perform: loadData)
        .navigationTitle("Geçmişler")
    }

    private func loadData() {
        PatientHistoryService.shared.getAllHistories { result in
            if case let .success(data) = result {
                histories = data
            } else {
                message = "Veriler getirilemedi."
            }
        }
    }
}
