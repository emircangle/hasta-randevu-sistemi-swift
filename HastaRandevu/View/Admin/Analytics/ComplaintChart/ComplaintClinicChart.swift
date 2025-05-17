import SwiftUI
import Charts

struct ComplaintClinicChart: View {
    @State private var clinicCounts: [ClinicComplaintCount] = []
    @State private var errorMessage: String?

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("🏥 Kliniklere Göre Şikayet Sayısı")
                .font(.title2)
                .bold()

            if let errorMessage {
                Text("❌ \(errorMessage)").foregroundColor(.red)
            } else if clinicCounts.isEmpty {
                ProgressView("Yükleniyor...")
            } else {
                Chart(clinicCounts, id: \.clinicName) { item in
                    BarMark(
                        x: .value("Klinik", item.clinicName),
                        y: .value("Şikayet Sayısı", item.complaintCount)
                    )
                }
                .frame(height: 300)
            }

            Spacer()
        }
        .padding()
        .onAppear(perform: loadComplaintClinicData)
    }

    private func loadComplaintClinicData() {
        AnalyticsService.shared.getComplaintCountByClinic { result in
            switch result {
            case .success(let data):
                self.clinicCounts = data
            case .failure(let error):
                self.errorMessage = error.localizedDescription
            }
        }
    }
}
