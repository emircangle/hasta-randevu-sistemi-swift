import SwiftUI

struct MainView: View {
    @State private var user: User?
    @State private var navigateToRandevuOlustur = false
    @State private var navigateToMyAppointments = false
    @State private var navigateToPrescriptions = false
    @State private var navigateToTestResults = false
    @State private var navigateToReports = false
    @State private var navigateToPatientHistory = false
    @State private var navigateToComplaint = false
    @State private var navigateToMyComplaints = false // ✅ Şikayetlerim eklendi

    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 16) {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        if let user = user {
                            Text("\(user.name) \(user.surname)")
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

                    // Menü
                    Menu {
                        Button("📅 Randevu Oluştur") {
                            navigateToRandevuOlustur = true
                        }
                        Button("📋 Randevularım") {
                            navigateToMyAppointments = true
                        }
                        Button("💊 Reçetelerim") {
                            navigateToPrescriptions = true
                        }
                        Button("🧪 Test Sonuçlarım") {
                            navigateToTestResults = true
                        }
                        Button("📄 Raporlarım") {
                            navigateToReports = true
                        }
                        Button("🧬 Sağlık Geçmişim") {
                            navigateToPatientHistory = true
                        }
                        Button("📢 Şikayet Oluştur") {
                            navigateToComplaint = true
                        }
                        Button("📨 Şikayetlerim") {
                            navigateToMyComplaints = true
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

                // Navigation yönlendirmeleri
                NavigationLink("", destination: AppointmentCreateView(), isActive: $navigateToRandevuOlustur).hidden()
                NavigationLink("", destination: MyAppointmentsView(), isActive: $navigateToMyAppointments).hidden()
                NavigationLink("", destination: MyPrescriptionsView(), isActive: $navigateToPrescriptions).hidden()
                NavigationLink("", destination: MyTestResultsView(), isActive: $navigateToTestResults).hidden()
                NavigationLink("", destination: MyReportsView(), isActive: $navigateToReports).hidden()
                NavigationLink("", destination: MyHealthHistoryView(), isActive: $navigateToPatientHistory).hidden()
                NavigationLink("", destination: CreateComplaintView(), isActive: $navigateToComplaint).hidden()
                NavigationLink("", destination: MyComplaintsView(), isActive: $navigateToMyComplaints).hidden()
            }
            .navigationTitle("")
            .navigationBarHidden(true)
            .onAppear(perform: loadUser)
            .overlay(alignment: .bottomTrailing) {
                AIChatView()
                    .padding(.trailing, 16)
                    .padding(.bottom, 32)
            }

        }
    }

    private func loadUser() {
        guard let email = getEmailFromToken() else {
            print("❌ Token'dan email çözülemedi.")
            return
        }

        UserService.shared.fetchUserByEmail(email: email) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let fetchedUser):
                    self.user = fetchedUser
                case .failure(let error):
                    print("❌ Kullanıcı bilgileri alınamadı: \(error.localizedDescription)")
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

    private func getEmailFromToken() -> String? {
        guard let token = UserDefaults.standard.string(forKey: "jwtToken") else {
            return nil
        }

        let parts = token.split(separator: ".")
        if parts.count > 1 {
            var payload = String(parts[1])
            while payload.count % 4 != 0 {
                payload += "="
            }

            if let payloadData = Data(base64Encoded: payload),
               let payloadJson = try? JSONSerialization.jsonObject(with: payloadData) as? [String: Any],
               let email = payloadJson["sub"] as? String {
                return email
            }
        }
        return nil
    }
}
