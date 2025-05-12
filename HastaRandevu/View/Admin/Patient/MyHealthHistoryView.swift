import SwiftUI

struct MyHealthHistoryView: View {
    @State private var histories: [PatientHistory] = []
    @State private var filteredHistories: [PatientHistory] = []
    @State private var selectedPeriod = "all"
    @State private var keyword = ""
    @State private var searchField = "diagnosis" // "treatment" seçeneği de olabilir
    @State private var patientId: Int?
    @State private var errorMessage: String?

    private let periodOptions = ["all", "day", "week", "month", "year"]

    var body: some View {
        VStack {
            Text("🩺 Sağlık Geçmişim")
                .font(.title)
                .bold()
                .padding()

            Picker("Zaman Filtresi", selection: $selectedPeriod) {
                ForEach(periodOptions, id: \.self) {
                    Text(labelForPeriod($0))
                }
            }
            .pickerStyle(SegmentedPickerStyle())
            .padding()
            .onChange(of: selectedPeriod) { _ in fetchHistories() }

            HStack {
                Picker("Alan", selection: $searchField) {
                    Text("Tanı").tag("diagnosis")
                    Text("Tedavi").tag("treatment")
                }
                .pickerStyle(SegmentedPickerStyle())

                TextField("Kelimeyle ara...", text: $keyword)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .onChange(of: keyword) { _ in search() }
            }
            .padding()

            if !filteredHistories.isEmpty {
                List(filteredHistories, id: \.id) { history in
                    VStack(alignment: .leading) {
                        Text("📅 Tarih: \(history.date)")
                        Text("🧬 Tanı: \(history.diagnosis)")
                        Text("💊 Tedavi: \(history.treatment)")
                        if let note = history.notes {
                            Text("📝 Not: \(note)")
                        }
                    }
                    .padding(.vertical, 5)
                }
            } else if errorMessage == nil {
                Text("Geçmiş bilgisi bulunamadı.")
                    .foregroundColor(.gray)
                    .padding()
            }

            if let error = errorMessage {
                Text("⚠️ \(error)")
                    .foregroundColor(.red)
                    .padding(.top)
            }

            Spacer()
        }
        .onAppear(perform: fetchUser)
        .overlay(alignment: .bottomTrailing) {
            AIChatView()
                .padding(.trailing, 16)
                .padding(.bottom, 32)
        }

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
                    fetchHistories()
                case .failure(let error):
                    self.errorMessage = "Kullanıcı alınamadı: \(error.localizedDescription)"
                }
            }
        }
    }

    private func fetchHistories() {
        guard let id = patientId else { return }
        errorMessage = nil

        let service = PatientHistoryService.shared
        let handler: (Result<[PatientHistory], Error>) -> Void = { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let data):
                    self.histories = data
                    self.filteredHistories = data
                case .failure(let error):
                    self.errorMessage = "Geçmiş alınamadı: \(error.localizedDescription)"
                }
            }
        }

        if selectedPeriod == "all" {
            service.getHistoriesByPatientId(id, completion: handler)
        } else {
            service.getHistoriesByPeriod(patientId: id, period: selectedPeriod, completion: handler)
        }
    }

    private func search() {
        guard !keyword.trimmingCharacters(in: .whitespaces).isEmpty else {
            filteredHistories = histories
            return
        }

        let completion: (Result<[PatientHistory], Error>) -> Void = { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let data):
                    self.filteredHistories = data
                case .failure(let error):
                    self.errorMessage = "Arama başarısız: \(error.localizedDescription)"
                }
            }
        }

        if searchField == "diagnosis" {
            PatientHistoryService.shared.searchByDiagnosis(keyword: keyword, completion: completion)
        } else {
            PatientHistoryService.shared.searchByTreatment(keyword: keyword, completion: completion)
        }
    }
}
