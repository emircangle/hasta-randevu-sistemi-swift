import SwiftUI

struct MyTestResultsView: View {
    @State private var results: [TestResult] = []
    @State private var selectedPeriod = "all"
    @State private var patientId: Int?
    @State private var errorMessage: String?

    private let periodOptions = ["all", "day", "week", "month", "year"]

    var body: some View {
        VStack {
            Text("🧪 Test Sonuçlarım")
                .font(.title)
                .bold()
                .padding(.top)

            Picker("Zaman Filtresi", selection: $selectedPeriod) {
                ForEach(periodOptions, id: \.self) { option in
                    Text(labelForPeriod(option))
                }
            }
            .pickerStyle(SegmentedPickerStyle())
            .padding()
            .onChange(of: selectedPeriod) { _ in fetchResults() }

            if !results.isEmpty {
                List(results, id: \.id) { t in
                    VStack(alignment: .leading, spacing: 6) {
                        Text("🧪 Test Adı: \(t.testName)")
                        Text("📅 Tarih: \(t.testDate)")
                        Text("🔬 Tür: \(t.testType)")
                        Text("📊 Sonuç: \(t.result)")
                        Text("🩺 Doktor Yorumu: \(t.doctorComment ?? "-")")
                    }
                    .padding(.vertical, 4)
                }
            } else if errorMessage == nil {
                Text("Gösterilecek test sonucu bulunamadı.")
                    .foregroundColor(.gray)
                    .padding()
            }

            if let error = errorMessage {
                Text("⚠️ \(error)").foregroundColor(.red).padding()
            }

            Spacer()
        }
        .onAppear(perform: fetchUser)
    }

    private func labelForPeriod(_ period: String) -> String {
        switch period {
        case "day": return "Son 1 Gün"
        case "week": return "Son 1 Hafta"
        case "month": return "Son 1 Ay"
        case "year": return "Son 1 Yıl"
        default: return "Tümü"
        }
    }

    private func fetchUser() {
        if let email = TokenUtil.getEmailFromToken() {
            UserService.shared.fetchUserByEmail(email: email) { result in
                switch result {
                case .success(let user):
                    self.patientId = user.id
                    fetchResults()
                case .failure(let error):
                    self.errorMessage = "Kullanıcı alınamadı: \(error.localizedDescription)"
                }
            }
        }
    }

    private func fetchResults() {
        guard let id = patientId else { return }
        errorMessage = nil

        if selectedPeriod == "all" {
            TestResultService.shared.getTestResultsByPatientId(id) { result in
                DispatchQueue.main.async {
                    switch result {
                    case .success(let data):
                        self.results = data
                    case .failure(let error):
                        self.errorMessage = "Sonuçlar alınamadı: \(error.localizedDescription)"
                    }
                }
            }
        } else {
            TestResultService.shared.getTestResultsByPatientAndPeriod(patientId: id, period: selectedPeriod) { result in
                DispatchQueue.main.async {
                    switch result {
                    case .success(let data):
                        self.results = data
                    case .failure(let error):
                        self.errorMessage = "Filtreli sonuçlar alınamadı: \(error.localizedDescription)"
                    }
                }
            }
        }
    }
}
