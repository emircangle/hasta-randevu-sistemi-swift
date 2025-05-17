import SwiftUI

struct UserAnalyticsTabView: View {
    enum UserAnalyticsTab: String, CaseIterable {
        case role = "Rol"
        case gender = "Cinsiyet"
        case blood = "Kan Grubu"
        case clinic = "Klinik"
    }

    @State private var selectedTab: UserAnalyticsTab = .role

    var body: some View {
        VStack(spacing: 16) {
            Text("👥 Kullanıcı Analizleri")
                .font(.title2)
                .bold()

            Picker("Kategori", selection: $selectedTab) {
                ForEach(UserAnalyticsTab.allCases, id: \.self) {
                    Text($0.rawValue)
                }
            }
            .pickerStyle(.segmented)
            .padding(.horizontal)

            Group {
                switch selectedTab {
                case .role:
                    UserRoleChart()
                case .gender:
                    UserGenderChart()
                case .blood:
                    UserBloodTypeChart()
                case .clinic:
                    DoctorCountByClinicChart()
                }
            }

            Spacer()
        }
        .padding()
        .navigationTitle("Kullanıcı Analizi")
    }
}
