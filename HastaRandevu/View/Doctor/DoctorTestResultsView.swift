import SwiftUI

struct DoctorTestResultsView: View {
    @State private var patients: [User] = []
    @State private var selectedPatientId: Int? = nil
    @State private var testResults: [TestResult] = []

    @State private var testName = ""
    @State private var testType = "DIGER"
    @State private var doctorComment = ""
    @State private var testDate = Date()
    @State private var mode: String = "" // "add", "list", ""

    @State private var patientMode: String = "today"
    @State private var doctorId: Int?
    @State private var isLoading = false
    @State private var errorMessage: String?

    var body: some View {
        NavigationStack {
            VStack(spacing: 16) {
                // Hasta türü seçimi
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

                // Hasta seçimi
                Picker("Hasta Seçin", selection: Binding(
                    get: { selectedPatientId ?? -1 },
                    set: { newValue in
                        selectedPatientId = newValue == -1 ? nil : newValue
                        mode = "" // hasta değişince mode sıfırlansın
                        testResults = [] // önceki testler temizlensin
                    })
                ) {
                    Text("-- Hasta Seçin --").tag(-1)
                    ForEach(patients, id: \.id) { patient in
                        Text("\(patient.name) \(patient.surname)").tag(patient.id)
                    }
                }
                .pickerStyle(.menu)

                // Hasta seçildiyse seçenekleri göster
                if let selectedId = selectedPatientId {
                    if mode.isEmpty {
                        if patientMode == "today" {
                            Button("Test Sonucu Ekle") {
                                mode = "add"
                            }
                        }
                        Button("Test Sonuçlarını Gör") {
                            fetchTestResults()
                            mode = "list"
                        }
                    } else if mode == "add" {
                        VStack(spacing: 8) {
                            TextField("Test Adı", text: $testName)
                                .textFieldStyle(RoundedBorderTextFieldStyle())

                            Picker("Test Türü", selection: $testType) {
                                Text("Diğer").tag("DIGER")
                                Text("Kan Tahlili").tag("KAN_TAHLILI")
                                Text("İdrar Tahlili").tag("IDRAR_TAHLILI")
                                Text("MRI").tag("MRI")
                                Text("Tomografi").tag("TOMOGRAFI")
                            }

                            TextField("Doktor Yorumu", text: $doctorComment)
                                .textFieldStyle(RoundedBorderTextFieldStyle())

                            DatePicker("Tarih", selection: $testDate, displayedComponents: .date)

                            Button("Kaydet") {
                                createTestResult()
                            }
                        }
                    } else if mode == "list" {
                        if isLoading {
                            ProgressView()
                        } else if testResults.isEmpty {
                            Text("📭 Kayıtlı test sonucu bulunmamaktadır.")
                                .foregroundColor(.gray)
                        } else {
                            List(testResults) { result in
                                VStack(alignment: .leading) {
                                    Text("🧪 \(result.testName)")
                                    Text("📅 \(result.testDate)")
                                    Text("📄 \(result.result)")
                                    Text("🗒️ \(result.doctorComment ?? "-")")
                                }
                            }
                        }
                    }


                    // Geri tuşu
                    Button("← Geri") {
                        mode = ""
                        selectedPatientId = nil
                        testResults = []
                    }
                }

                Spacer()
            }
            .padding()
            .navigationTitle("Test Sonuçları")
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

    private func fetchTestResults() {
        guard let selectedPatientId else { return }
        isLoading = true
        DoctorTestResultService.shared.getTestResultsByPatientId(patientId: selectedPatientId) { result in
            DispatchQueue.main.async {
                isLoading = false
                switch result {
                case .success(let data): testResults = data
                case .failure(let error): errorMessage = error.localizedDescription
                }
            }
        }
    }

    private func createTestResult() {
        guard let selectedPatientId else { return }

        let request = TestResultRequest(
            patient: PatientReference(id: selectedPatientId),
            testName: testName.isEmpty ? "Test - \(testType)" : testName,
            testType: testType,
            result: "Sonuç bilgisi manuel girildi.",
            doctorComment: doctorComment,
            testDate: formatDate(testDate)
        )

        DoctorTestResultService.shared.createTestResult(request: request) { result in
            DispatchQueue.main.async {
                switch result {
                case .success:
                    testName = ""
                    doctorComment = ""
                    testDate = Date()
                    mode = ""
                    fetchTestResults()
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
