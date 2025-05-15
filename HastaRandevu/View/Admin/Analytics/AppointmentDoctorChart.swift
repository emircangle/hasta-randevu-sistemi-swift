import SwiftUI
import Charts

struct AppointmentDoctorChart: View {
    @State private var data: [DoctorAppointmentCount] = []
    @State private var errorMessage: String?

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("👨‍⚕️ Doktor Bazlı Randevu Yoğunluğu")
                .font(.title2)
                .bold()

            if let errorMessage = errorMessage {
                Text("❌ \(errorMessage)")
                    .foregroundColor(.red)
            } else if data.isEmpty {
                ProgressView("Yükleniyor...")
            } else {
                Chart(data, id: \.doctorName) { item in
                    BarMark(
                        x: .value("Doktor", item.doctorName),
                        y: .value("Randevu Sayısı", item.appointmentCount)
                    )
                }
                .frame(height: 300)
                .chartXAxis {
                    AxisMarks(values: .automatic) { value in
                        AxisGridLine()
                        AxisTick()
                        AxisValueLabel(){
                            if let stringValue = value.as(String.self) {
                                Text(stringValue)
                                    .rotationEffect(.degrees(45))
                            }
                        }
                    }
                }
            }

            Spacer()
        }
        .padding()
        .onAppear(perform: loadData)
    }

    private func loadData() {
        AnalyticsService.shared.getAppointmentCountByDoctor { result in
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
