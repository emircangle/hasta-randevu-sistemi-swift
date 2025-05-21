import SwiftUI

struct TestResultsExportView: View {
    @State private var results: [TestResult] = []
    @State private var message: String?

    var body: some View {
        VStack(spacing: 12) {
            Text("🧪 Test Sonuçları Verileri").font(.title2).bold()

            if results.isEmpty {
                ProgressView("Veriler getiriliyor...")
            } else {
                ScrollView(.horizontal) {
                    Table(results) {
                        TableColumn("ID") { Text("\($0.id)") }
                        TableColumn("Hasta") { Text("\($0.patient.name ?? "-") \($0.patient.surname ?? "")")
 }
                        TableColumn("Doktor") { Text("\($0.doctor.name ?? "-") \($0.doctor.surname ?? "")") }
                        TableColumn("Tarih") { Text($0.testDate) }
                        TableColumn("Adı") { Text($0.testName) }
                        TableColumn("Türü") { Text($0.testType) }
                        TableColumn("Sonuç") { Text($0.result) }
                        TableColumn("Yorum") { Text($0.doctorComment ?? "-") }
                    }
                }

                Button("⬇️ CSV Olarak İndir") {
                    ExportService.shared.exportTestResults { result in
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
        .navigationTitle("Test Sonuçları")
    }

    private func loadData() {
        TestResultService.shared.getAllTestResults { result in
            if case let .success(data) = result {
                results = data
            } else {
                message = "Veriler getirilemedi."
            }
        }
    }
}
