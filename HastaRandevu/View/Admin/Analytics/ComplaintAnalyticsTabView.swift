import SwiftUI

struct ComplaintAnalyticsTabView: View {
    enum ComplaintTab: String, CaseIterable {
        case status = "Durum"
        case clinic = "Klinik"
        case subject = "Konu"
    }

    @State private var selectedTab: ComplaintTab = .status

    var body: some View {
        VStack(spacing: 16) {
            Text("📈 Şikayet Analizleri")
                .font(.title2)
                .bold()

            Picker("Kategori", selection: $selectedTab) {
                ForEach(ComplaintTab.allCases, id: \.self) { tab in
                    Text(tab.rawValue)
                }
            }
            .pickerStyle(SegmentedPickerStyle())
            .padding(.horizontal)

            Group {
                switch selectedTab {
                case .status:
                    ComplaintStatusChart()
                case .clinic:
                    ComplaintClinicChart()
                case .subject:
                    ComplaintSubjectChart()
                }
            }

            Spacer()
        }
        .padding()
        .navigationTitle("Şikayet Analizi")
    }

}
