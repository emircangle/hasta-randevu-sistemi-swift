import SwiftUI
import Charts

struct ComplaintStatusChart: View {
    @State private var statusCounts: [ComplaintStatusCount] = []
    @State private var errorMessage: String?

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("📊 Şikayet Durum Dağılımı")
                .font(.title2)
                .bold()

            if let errorMessage {
                Text("❌ \(errorMessage)").foregroundColor(.red)
            } else if statusCounts.isEmpty {
                ProgressView("Yükleniyor...")
            } else {
                Chart(statusCounts, id: \.status) { item in
                    SectorMark(
                        angle: .value("Adet", item.count),
                        innerRadius: .ratio(0.5),
                        angularInset: 2
                    )
                    .foregroundStyle(by: .value("Durum", item.status))
                }
                .frame(height: 300)
            }

            Spacer()
        }
        .padding()
        .onAppear(perform: loadComplaintStatusData)
    }

    private func loadComplaintStatusData() {
        AnalyticsService.shared.getComplaintCountByStatus { result in
            switch result {
            case .success(let data):
                self.statusCounts = data
            case .failure(let error):
                self.errorMessage = error.localizedDescription
            }
        }
    }
}
