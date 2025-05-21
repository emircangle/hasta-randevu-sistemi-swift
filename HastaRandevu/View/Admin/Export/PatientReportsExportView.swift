import SwiftUI

struct PatientReportsExportView: View {
    @State private var reports: [PatientReport] = []
    @State private var message: String?

    var body: some View {
        VStack(spacing: 12) {
            Text("📝 Hasta Raporları").font(.title2).bold()

            if reports.isEmpty {
                ProgressView("Veriler getiriliyor...")
            } else {
                ScrollView(.horizontal) {
                    Table(reports) {
                        TableColumn("ID") { Text("\($0.id)") }
                        TableColumn("Hasta") { Text("\($0.patient.name ?? "-") \($0.patient.surname ?? "")") }
                        TableColumn("Doktor") { Text("\($0.doctor.name ?? "-") \($0.doctor.surname ?? "")") }
                        TableColumn("Tür") { Text($0.reportType) }
                        TableColumn("Tarih") { Text($0.reportDate) }
                        TableColumn("Dosya") {
                            Text($0.fileUrl) // ✅ çünkü non-optional
                        }
                    }
                }

                Button("⬇️ CSV Olarak İndir") {
                    ExportService.shared.exportPatientReports { result in
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
        .navigationTitle("Raporlar")
    }

    private func loadData() {
        PatientReportService.shared.getAllReports { result in
            if case let .success(data) = result {
                reports = data
            } else {
                message = "Veriler getirilemedi."
            }
        }
    }
}
