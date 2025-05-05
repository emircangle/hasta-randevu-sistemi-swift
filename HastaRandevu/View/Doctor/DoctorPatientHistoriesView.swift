import SwiftUI

struct DoctorPatientHistoriesView: View {
    @State private var patients: [User] = []
    @State private var selectedPatientId: Int? = nil
    @State private var patientHistories: [DoctorPatientHistory] = []

    @State private var title = ""
    @State private var historyDescription = ""
    @State private var historyDate = Date()
    @State private var mode: String = "" // "", "add", "list"

    @State private var patientMode: String = "today"
    @State private var doctorId: Int?
    @State private var isLoading = false
    @State private var errorMessage: String?

    var body: some View {
        NavigationStack {
            VStack(spacing: 16) {
                // Hasta Türü Seçimi
                HStack {
                    Button("Randevulu Hastalar") {
                        patientMode = "today"
                        selectedPatientId = nil
                        mode = ""
                        fetchPatients()
                    }
                    .disabled(patientMode == "today")

                    Button("Randevusuz Hastalar") {
                        patientMode = "all"
                        selectedPatientId = nil
                        mode = ""
                        fetchPatients()
                    }
                    .disabled(patientMode == "all")
                }

                // Hasta Seçimi
                Picker("Hasta Seçin", selection: Binding(
                    get: { selectedPatientId ?? -1 },
                    set: { selectedPatientId = $0 == -1 ? nil : $0 })
                ) {
                    Text("-- Hasta Seçin --").tag(-1)
                    ForEach(patients, id: \.id) { patient in
                        Text("\(patient.name) \(patient.surname)").tag(patient.id)
                    }
                }
                .pickerStyle(.menu)

                // Hasta Seçildiyse
                if let _ = selectedPatientId {
                    if mode == "" {
                        if patientMode == "today" {
                            Button("Geçmiş Ekle") {
                                mode = "add"
                            }
                        }
                        Button("Geçmişi Gör") {
                            fetchHistories()
                            mode = "list"
                        }
                    } else if mode == "add" {
                        VStack(spacing: 8) {
                            TextField("Başlık", text: $title)
                                .textFieldStyle(RoundedBorderTextFieldStyle())

                            TextField("Açıklama", text: $historyDescription)
                                .textFieldStyle(RoundedBorderTextFieldStyle())

                            DatePicker("Tarih", selection: $historyDate, displayedComponents: .date)

                            Button("Kaydet") {
                                createHistory()
                            }
                        }
                    } else if mode == "list" {
                        if isLoading {
                            ProgressView()
                        } else if patientHistories.isEmpty {
                            Text("Bu hastaya ait geçmiş kaydı yok.")
                                .foregroundColor(.gray)
                        } else {
                            List(patientHistories) { history in
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("📌 Başlık: \(history.title)")
                                    Text("📅 Tarih: \(history.date)")
                                    Text("📄 Açıklama: \(history.description)")
                                }
                            }
                        }
                    }

                    Button("← Geri") {
                        mode = ""
                        selectedPatientId = nil
                        patientHistories = []
                    }
                }

                Spacer()
            }
            .padding()
            .navigationTitle("Hasta Geçmişleri")
            .onAppear(perform: fetchDoctorInfo)
        }
    }

    private func fetchDoctorInfo() {
        guard let email = TokenUtil.getEmailFromToken() else { return }
        UserService.shared.fetchUserByEmail(email: email) { result in
            if case let .success(user) = result {
                doctorId = user.id
                fetchPatients()
            }
        }
    }

    private func fetchPatients() {
        guard let doctorId else { return }

        let fetchFunc = patientMode == "today"
            ? DoctorPatientService.shared.getMyPatientsToday
            : DoctorPatientService.shared.getMyPatients

        fetchFunc { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let data): patients = data
                case .failure(let error): errorMessage = error.localizedDescription
                }
            }
        }
    }

    private func fetchHistories() {
        guard let selectedPatientId else { return }
        isLoading = true
        DoctorPatientHistoryService.shared.getHistoriesByPatientId(selectedPatientId) { result in
            DispatchQueue.main.async {
                isLoading = false
                switch result {
                case .success(let data): patientHistories = data.map {
                    DoctorPatientHistory(
                        id: $0.id,
                        title: $0.title,
                        description: $0.description,
                        date: $0.date,
                        doctor: $0.doctor,
                        patient: $0.patient
                    )
                }
                case .failure(let error): errorMessage = error.localizedDescription
                }
            }
        }
    }

    private func createHistory() {
        guard let selectedPatientId else { return }

        let request = DoctorPatientHistoryRequest(
            patient: PatientReference(id: selectedPatientId),
            title: title,
            description: historyDescription,
            date: formatDate(historyDate)
        )

        DoctorPatientHistoryService.shared.createHistory(request) { result in
            DispatchQueue.main.async {
                switch result {
                case .success:
                    title = ""
                    historyDescription = ""
                    historyDate = Date()
                    mode = ""
                    fetchHistories()
                case .failure(let error):
                    errorMessage = error.localizedDescription
                }
            }
        }
    }

    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: date)
    }
}
