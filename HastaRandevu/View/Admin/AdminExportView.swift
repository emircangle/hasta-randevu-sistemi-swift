import SwiftUI

struct AdminExportView: View {
    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                Text("📦 Veri İndirme Paneli")
                    .font(.title2)
                    .bold()

                // Yönlendirme butonları
                NavigationLink("👤 Kullanıcılar", destination: UsersExportView())
                    .buttonStyle(.borderedProminent)

                NavigationLink("📅 Randevular", destination: AppointmentsExportView())
                    .buttonStyle(.borderedProminent)

                NavigationLink("📋 Şikayetler", destination: ComplaintsExportView())
                    .buttonStyle(.borderedProminent)

                NavigationLink("💊 Reçeteler", destination: PrescriptionsExportView())
                    .buttonStyle(.borderedProminent)

                NavigationLink("🧪 Test Sonuçları", destination: TestResultsExportView())
                    .buttonStyle(.borderedProminent)

                NavigationLink("📚 Hasta Geçmişleri", destination: PatientHistoriesExportView())
                    .buttonStyle(.borderedProminent)

                NavigationLink("📝 Hasta Raporları", destination: PatientReportsExportView())
                    .buttonStyle(.borderedProminent)

                Spacer()
            }
            .padding()
            .navigationTitle("Export Paneli")
        }
    }
}
