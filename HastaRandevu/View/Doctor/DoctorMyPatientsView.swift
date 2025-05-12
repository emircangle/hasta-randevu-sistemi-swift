import SwiftUI

struct DoctorMyPatientsView: View {
    @State private var doctor: User?
    @State private var allStats: [DoctorPatientStats] = []
    @State private var searchQuery = ""
    @State private var searchType: SearchType = .name

    enum SearchType: String, CaseIterable {
        case name = "İsim"
        case email = "Email"
    }

    var filteredStats: [DoctorPatientStats] {
        let query = searchQuery.lowercased()
        switch searchType {
        case .name:
            return allStats.filter { $0.name.lowercased().contains(query) || $0.surname.lowercased().contains(query) }
        case .email:
            return allStats.filter { $0.email.lowercased().contains(query) }
        }
    }

    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 16) {
                Text("📋 Hastalarım")
                    .font(.title)
                    .bold()

                HStack {
                    TextField("Arama...", text: $searchQuery)
                        .textFieldStyle(.roundedBorder)

                    Picker("Arama Türü", selection: $searchType) {
                        ForEach(SearchType.allCases, id: \.self) {
                            Text($0.rawValue)
                        }
                    }
                    .pickerStyle(.menu)
                }

                if filteredStats.isEmpty {
                    Text("Kayıtlı hasta bulunamadı.").foregroundColor(.gray)
                } else {
                    List(filteredStats, id: \.id) { stat in
                        VStack(alignment: .leading, spacing: 6) {
                            Text("👤 \(stat.name) \(stat.surname)").font(.headline)
                            Text("📧 \(stat.email)")
                            Text("📱 \(stat.phoneNumber)")
                            Text("🎂 Doğum: \(stat.birthDate ?? "-") | 🩸 Kan: \(stat.bloodType ?? "-")")
                            HStack {
                                Text("📅 R: \(stat.appointmentCount)")
                                Text("💊 Rç: \(stat.prescriptionCount)")
                                Text("🧪 T: \(stat.testResultCount)")
                                Text("📚 G: \(stat.historyCount)")
                                Text("📄 Rp: \(stat.reportCount)")
                            }
                            .font(.subheadline)
                        }
                        .padding(.vertical, 8)
                    }
                }

                Spacer()
            }
            .padding()
            .onAppear(perform: loadData)
        }
    }

    private func loadData() {
        guard let email = TokenUtil.getEmailFromToken() else { return }

        UserService.shared.fetchUserByEmail(email: email) { result in
            switch result {
            case .success(let user):
                self.doctor = user
                loadPatients(for: user.id)
            case .failure(let error):
                print("❌ Doktor verisi alınamadı: \(error.localizedDescription)")
            }
        }
    }

    private func loadPatients(for doctorId: Int) {
        DoctorPatientService.shared.getMyPatients { result in
            switch result {
            case .success(let patients):
                fetchAllStats(for: doctorId, patients: patients)
            case .failure(let error):
                print("❌ Hastalar alınamadı: \(error.localizedDescription)")
            }
        }
    }

    private func fetchAllStats(for doctorId: Int, patients: [User]) {
        let group = DispatchGroup()

        var appointments: [DoctorAppointment] = []
        var prescriptions: [Prescription] = []
        var testResults: [TestResult] = []
        var histories: [DoctorPatientHistory] = []
        var reports: [PatientReport] = []

        group.enter()
        DoctorService.shared.getAppointmentsByDoctor(doctorId: doctorId) {
            if case .success(let data) = $0 { appointments = data }
            group.leave()
        }

        group.enter()
        DoctorPrescriptionService.shared.getPrescriptionsByDoctor(doctorId: doctorId) {
            if case .success(let data) = $0 { prescriptions = data }
            group.leave()
        }

        group.enter()
        DoctorTestResultService.shared.getTestResultsByDoctorId(doctorId: doctorId) {
            if case .success(let data) = $0 { testResults = data }
            group.leave()
        }

        group.enter()
        DoctorPatientHistoryService.shared.getHistoriesByDoctorId(doctorId) {
            if case .success(let data) = $0 { histories = data }
            group.leave()
        }

        group.enter()
        DoctorPatientReportService.shared.getReportsByDoctorId(doctorId: doctorId) {
            if case .success(let data) = $0 { reports = data }
            group.leave()
        }

        group.notify(queue: .main) {
            let appointmentMap = buildCountMap(appointments.map { $0.patient }, idKey: \.id)
            let prescriptionMap = buildCountMap(prescriptions.map { $0.patient }, idKey: \.id)
            let testResultMap = buildCountMap(testResults.map { $0.patient }, idKey: \.id)
            let historyMap = buildCountMap(histories.map { $0.patient }, idKey: \.id)
            let reportMap = buildCountMap(reports.map { $0.patient }, idKey: \.id)


            let resultStats = patients.map { patient in
                DoctorPatientStats(
                    id: patient.id,
                    name: patient.name,
                    surname: patient.surname,
                    email: patient.email,
                    phoneNumber: patient.phoneNumber,
                    birthDate: patient.birthDate,
                    bloodType: patient.bloodType,
                    appointmentCount: appointmentMap[patient.id] ?? 0,
                    prescriptionCount: prescriptionMap[patient.id] ?? 0,
                    testResultCount: testResultMap[patient.id] ?? 0,
                    historyCount: historyMap[patient.id] ?? 0,
                    reportCount: reportMap[patient.id] ?? 0
                )
            }

            self.allStats = resultStats
        }
    }

    private func buildCountMap<T>(_ items: [T], idKey: KeyPath<T, Int>) -> [Int: Int] {
        var map: [Int: Int] = [:]
        for item in items {
            let id = item[keyPath: idKey]
            map[id, default: 0] += 1
        }
        return map
    }

}
