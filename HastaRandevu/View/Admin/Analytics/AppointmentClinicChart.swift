import SwiftUI
import Charts

struct AppointmentClinicChart: View {
    @State private var clinicData: [ClinicAppointmentCount] = []
    @State private var isLoading = true
    @State private var errorMessage: String?

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("📍 Klinik Bazlı Randevu Dağılımı")
                .font(.headline)

            if isLoading {
                ProgressView("Yükleniyor...")
            } else if let errorMessage {
                Text("❌ Hata: \(errorMessage)").foregroundColor(.red)
            } else if clinicData.isEmpty {
                Text("📭 Veri bulunamadı.").foregroundColor(.gray)
            } else {
                Chart(clinicData, id: \.clinicName) { item in
                    BarMark(
                        x: .value("Klinik", item.clinicName),
                        y: .value("Randevu", item.appointmentCount)
                    )
                    .foregroundStyle(Color.blue)
                }
                .frame(height: 300)
            }
        }
        .padding(.vertical)
        .onAppear(perform: loadClinicData)
    }

    private func loadClinicData() {
        isLoading = true
        AnalyticsService.shared.getAppointmentCountByClinic { result in
            DispatchQueue.main.async {
                isLoading = false
                switch result {
                case .success(let data):
                    self.clinicData = data
                case .failure(let error):
                    self.errorMessage = error.localizedDescription
                }
            }
        }
    }
}
