import SwiftUI

struct AdminAnalyticsView: View {
    enum AnalyticsTab: String, CaseIterable {
        case clinic = "Klinik"
        case date = "Tarih"
        case status = "Durum"
        case doctor = "Doktor"
    }

    @State private var selectedTab: AnalyticsTab = .clinic

    var body: some View {
        VStack {
            Text("📊 İstatistik ve Analiz Paneli")
                .font(.title2)
                .bold()
                .padding(.top)

            // Sekmeler
            Picker("Analiz Türü", selection: $selectedTab) {
                ForEach(AnalyticsTab.allCases, id: \.self) {
                    Text($0.rawValue)
                }
            }
            .pickerStyle(SegmentedPickerStyle())
            .padding()

            // İçerik
            switch selectedTab {
            case .clinic:
                AppointmentClinicChart()
            case .date:
                AppointmentDateChart()
            case .status:
                AppointmentStatusChart()
            case .doctor:
                AppointmentDoctorChart()
            }
        }
        .padding()
        .navigationTitle("Admin Paneli")
    }
}
