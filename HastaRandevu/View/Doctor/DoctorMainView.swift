import SwiftUI

struct DoctorMainView: View {
    @State private var user: User?
    @State private var navigateToIncomingAppointments = false
    @State private var navigateToDoctorPrescriptions = false
    @State private var navigateToDoctorTestResults = false
    @State private var navigateToDoctorPatientHistories = false
    @State private var navigateToDoctorPatientReports = false
    @State private var navigateToMyPatients = false

    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 16) {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        if let user = user {
                            Text("👨‍⚕️ Dr. \(user.name) \(user.surname)")
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
                        Button("📅 Gelen Randevular") {
                            navigateToIncomingAppointments = true
                        }
                        Button("🧾 Reçeteler") {
                            navigateToDoctorPrescriptions = true
                        }
                        Button("🧪 Test Sonuçları") {
                            navigateToDoctorTestResults = true
                        }
                        Button("📚 Hasta Geçmişleri") {
                            navigateToDoctorPatientHistories = true
                        }
                        Button("📄 Hasta Raporları") {
                            navigateToDoctorPatientReports = true
                        }
                        Button("🔍 Hastalarım") {
                            navigateToMyPatients = true
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
                NavigationLink("", destination: DoctorAppointmentsView(), isActive: $navigateToIncomingAppointments).hidden()
                NavigationLink("", destination: DoctorPrescriptionsView(), isActive: $navigateToDoctorPrescriptions).hidden()
                /*
                NavigationLink("", destination: DoctorTestResultsView(), isActive: $navigateToDoctorTestResults).hidden()
                NavigationLink("", destination: DoctorPatientHistoriesView(), isActive: $navigateToDoctorPatientHistories).hidden()
                NavigationLink("", destination: DoctorPatientReportsView(), isActive: $navigateToDoctorPatientReports).hidden()
                NavigationLink("", destination: MyPatientsView(), isActive: $navigateToMyPatients).hidden()
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
}
