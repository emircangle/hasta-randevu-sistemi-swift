import SwiftUI
import Charts

struct AppointmentStatusChart: View {
    @State private var data: [AppointmentStatusCount] = []
    @State private var errorMessage: String?

    let statusLabels: [String] = ["AKTIF", "IPTAL_EDILDI", "COMPLETED", "GEC_KALINDI"]

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("📌 Randevu Durumlarına Göre Dağılım")
                .font(.title2)
                .bold()

            if let errorMessage = errorMessage {
                Text("❌ \(errorMessage)")
                    .foregroundColor(.red)
            } else if data.isEmpty {
                ProgressView("Yükleniyor...")
            } else {
                Chart {
                    ForEach(data, id: \.status) { item in
                        SectorMark(
                            angle: .value("Sayı", item.count),
                            innerRadius: .ratio(0.5),
                            angularInset: 2
                        )
                        .foregroundStyle(by: .value("Durum", item.status))
                        .annotation(position: .overlay) {
                            Text(item.status)
                                .font(.caption2)
                                .foregroundColor(.white)
                        }
                    }
                }
                .frame(height: 300)
            }

            Spacer()
        }
        .padding()
        .onAppear(perform: loadData)
    }

    private func loadData() {
        AnalyticsService.shared.getAppointmentCountByStatus { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let list):
                    self.data = list
                case .failure(let error):
                    self.errorMessage = "Veri alınamadı: \(error.localizedDescription)"
                }
            }
        }
    }
}
