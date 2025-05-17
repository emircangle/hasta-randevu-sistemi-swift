import SwiftUI
import Charts

struct AppointmentDateChart: View {
    @State private var data: [DateAppointmentCount] = []
    @State private var errorMessage: String?

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("📅 Günlük Randevu Dağılımı")
                .font(.title2)
                .bold()

            if let error = errorMessage {
                Text("❌ \(error)")
                    .foregroundColor(.red)
            } else if data.isEmpty {
                ProgressView("Yükleniyor...")
            } else {
                Chart(data) { item in
                    LineMark(
                        x: .value("Tarih", item.date),
                        y: .value("Randevu Sayısı", item.appointmentCount)
                    )
                    .interpolationMethod(.catmullRom)
                    .symbol(.circle)
                }
                .frame(height: 300)
            }

            Spacer()
        }
        .padding()
        .onAppear(perform: loadData)
    }

    private func loadData() {
        AnalyticsService.shared.getAppointmentCountByDate { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let response):
                    self.data = response
                case .failure(let error):
                    self.errorMessage = "Veri alınamadı: \(error.localizedDescription)"
                }
            }
        }
    }
}
