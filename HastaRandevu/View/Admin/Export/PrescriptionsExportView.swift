import SwiftUI

struct PrescriptionsExportView: View {
    @State private var prescriptions: [Prescription] = []
    @State private var message: String?

    var body: some View {
        VStack(spacing: 12) {
            Text("💊 Reçete Verileri").font(.title2).bold()

            if prescriptions.isEmpty {
                ProgressView("Veriler getiriliyor...")
            } else {
                ScrollView(.horizontal) {
                    Table(prescriptions) {
                        TableColumn("ID") { Text("\($0.id)") }
                        TableColumn("Kod") { Text($0.prescriptionCode) }
                        TableColumn("Tarih") { Text($0.date) }
                        TableColumn("Açıklama") { Text($0.description ?? "-") } // ✅
                        TableColumn("İlaçlar") { Text($0.medications) }
                        TableColumn("Doktor") {
                            Text("\($0.doctor.name ?? "-") \($0.doctor.surname ?? "")")
                        }
                        TableColumn("Hasta") {
                            Text("\($0.patient.name ?? "-") \($0.patient.surname ?? "")")
                        }
                        
                    }
                }


                Button("⬇️ CSV Olarak İndir") {
                    ExportService.shared.exportPrescriptions { result in
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
        .navigationTitle("Reçeteler")
    }

    private func loadData() {
        PrescriptionService.shared.getAllPrescriptions { result in
            if case let .success(data) = result {
                prescriptions = data
            } else {
                message = "Veriler getirilemedi."
            }
        }
    }
}
