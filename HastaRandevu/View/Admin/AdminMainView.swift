import SwiftUI

struct AdminMainView: View {
    @State private var user: User?

    // Navigation state'leri
    @State private var navigateToUsers = false
    @State private var navigateToComplaints = false
    @State private var navigateToAppointments = false
    @State private var navigateToAnalytics = false
    @State private var navigateToExport = false
    @State private var navigateToLogs = false
    @State private var navigateToAI = false

    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 16) {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        if let user = user {
                            Text("🛠️ Admin: \(user.name) \(user.surname)")
                                .font(.title)
                                .bold()
                            Text(user.email)
                                .font(.subheadline)
                                .foregroundColor(.gray)
                        } else {
                            ProgressView()
                        }
                    }

                    Spacer()

                    Menu {
                        Button("👥 Kullanıcıları Yönet") {
                            navigateToUsers = true
                        }
                        Button("📢 Şikayetleri Görüntüle") {
                            navigateToComplaints = true
                        }
                        Button("📅 Randevuları Görüntüle") {
                            navigateToAppointments = true
                        }
                        Button("📊 İstatistik ve Analiz") {
                            navigateToAnalytics = true
                        }
                        Button("📤 Verileri Dışa Aktar") {
                            navigateToExport = true
                        }
                        Button("📜 Erişim Kayıtları") {
                            navigateToLogs = true
                        }
                        Button("🤖 AI Klinik Önerileri") {
                            navigateToAI = true
                        }

                        Divider()
                        Button("🚪 Çıkış Yap", role: .destructive, action: logout)
                    } label: {
                        Image(systemName: "line.3.horizontal")
                            .imageScale(.large)
                            .padding()
                    }
                }
                .padding()

                Spacer()

                // Navigasyon bağlantıları
                NavigationLink("", destination: AdminUserListView(), isActive: $navigateToUsers).hidden()
                NavigationLink("", destination: AdminComplaintsView(), isActive: $navigateToComplaints).hidden()
                NavigationLink("", destination: AdminAppointmentsView(), isActive: $navigateToAppointments).hidden()
                NavigationLink("", destination: AdminAnalyticsView(), isActive: $navigateToAnalytics).hidden()
                /*
                NavigationLink("", destination: AdminExportView(), isActive: $navigateToExport).hidden()
                NavigationLink("", destination: AdminLogsView(), isActive: $navigateToLogs).hidden()
                NavigationLink("", destination: AdminAIChatView(), isActive: $navigateToAI).hidden()
                 */
            }
            .navigationTitle("")
            .navigationBarHidden(true)
            .onAppear(perform: loadUser)
        }
    }

    private func loadUser() {
        guard let email = TokenUtil.getEmailFromToken() else {
            print("❌ Token'dan email çözülemedi.")
            return
        }

        UserService.shared.fetchUserByEmail(email: email) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let fetchedUser):
                    self.user = fetchedUser
                case .failure(let error):
                    print("❌ Kullanıcı bilgisi alınamadı: \(error.localizedDescription)")
                }
            }
        }
    }

    private func logout() {
        UserDefaults.standard.removeObject(forKey: "jwtToken")

        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let window = windowScene.windows.first {
            window.rootViewController = UIHostingController(rootView: WelcomeView())
            window.makeKeyAndVisible()
        }
    }
}
