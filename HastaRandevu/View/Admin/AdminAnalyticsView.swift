import SwiftUI

struct AdminAnalyticsView: View {
    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                Text("📊 İstatistik ve Analiz Paneli")
                    .font(.title2)
                    .bold()
                    .padding(.top)

              // 3 Buton
                NavigationLink(destination: UserAnalyticsTabView()) {
                    analyticsButtonLabel("👤 Kullanıcı Analizi")
                }

                NavigationLink(destination: AppointmentAnalyticsTabView()) {
                    analyticsButtonLabel("📅 Randevu Analizi")
                }

                NavigationLink(destination: ComplaintAnalyticsTabView()) {
                    analyticsButtonLabel("📝 Şikayet Analizi")
                }


                Spacer()
            }
            .padding()
            .navigationTitle("Admin Paneli")
        }
    }

    // Tekrarlı buton stilini fonksiyonla yönettik
    private func analyticsButtonLabel(_ title: String) -> some View {
        Text(title)
            .frame(maxWidth: .infinity)
            .padding()
            .background(Color.blue.opacity(0.2))
            .foregroundColor(.blue)
            .cornerRadius(12)
            .font(.headline)
    }
}
