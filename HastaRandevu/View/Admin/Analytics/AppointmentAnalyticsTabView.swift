import SwiftUI

struct AppointmentAnalyticsTabView: View {
    enum AnalyticsTab: String, CaseIterable {
        case clinic = "Klinik"
        case doctor = "Doktor"
        case status = "Durum"
        case date = "Tarih"
    }

    @State private var selectedTab: AnalyticsTab = .clinic

    var body: some View {
        VStack(spacing: 16) {
            Text("📈 Randevu Analizleri")
                .font(.title2)
                .bold()

            Picker("Kategori", selection: $selectedTab) {
                ForEach(AnalyticsTab.allCases, id: \.self) { tab in
                    Text(tab.rawValue)
                }
            }
            .pickerStyle(SegmentedPickerStyle())
            .padding(.horizontal)

            // Sekmeye göre grafik gösterimi
            Group {
                switch selectedTab {
                case .clinic:
                    AppointmentClinicChart()
                case .doctor:
                    AppointmentDoctorChart()
                case .status:
                    AppointmentStatusChart()
                case .date:
                    AppointmentDateChart()
                }
            }

            Spacer()
        }
        .padding()
        .navigationTitle("Randevu Analizi")
    }
}
