import SwiftUI

struct DoctorPrescriptionsView: View {
    @State private var doctor: User?
    @State private var patients: [User] = []
    @State private var prescriptions: [Prescription] = []
    @State private var selectedPatientId: Int?
    @State private var medications = ""
    @State private var description = ""
    @State private var patientMode: String = "today"
    @State private var errorMessage: String?
    @State private var showList = false
    @State private var isLoading = false

    var body: some View {
        NavigationView {
            VStack(spacing: 12) {
                Picker("Hasta Modu", selection: $patientMode) {
                    Text("Randevulu").tag("today")
                    Text("Randevusuz").tag("all")
                }
                .pickerStyle(SegmentedPickerStyle())
                .onChange(of: patientMode) { _ in
                    selectedPatientId = nil
                    loadPatients()
                }

                Picker("Hasta Seç", selection: $selectedPatientId) {
                    Text("-- Seçin --").tag(nil as Int?)
                    ForEach(patients, id: \.id) { patient in
                        Text("\(patient.name) \(patient.surname)").tag(patient.id as Int?)
                    }
                }

                if let id = selectedPatientId {
                    HStack {
                        Button("Reçete Yaz") {
                            showList = false
                        }
                        Button("Reçeteleri Gör") {
                            showList = true
                            loadPrescriptions()
                        }
                    }
                }

                if showList {
                    if prescriptions.isEmpty {
                        Text("Reçete bulunamadı.")
                    } else {
                        List(prescriptions) { pres in
                            VStack(alignment: .leading) {
                                Text("👤 Hasta: \(pres.patient.name) \(pres.patient.surname)")
                                Text("💊 \(pres.medications)")
                                Text("📝 \(pres.description ?? "-")")
                                Text("📅 \(pres.date)")
                            }
                        }
                    }
                } else {
                    TextField("İlaçlar", text: $medications)
                        .textFieldStyle(RoundedBorderTextFieldStyle())

                    TextEditor(text: $description)
                        .frame(height: 80)
                        .overlay(RoundedRectangle(cornerRadius: 5).stroke(Color.gray))

                    Button("Reçete Oluştur") {
                        createPrescription()
                    }
                    .disabled(selectedPatientId == nil || medications.isEmpty || description.isEmpty)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
                }

                if let error = errorMessage {
                    Text("❌ \(error)").foregroundColor(.red)
                }

                Spacer()
            }
            .padding()
            .navigationTitle("🧾 Reçeteler")
            .onAppear {
                loadDoctor()
            }
        }
    }

    private func loadDoctor() {
        guard let email = TokenUtil.getEmailFromToken() else { return }
        UserService.shared.fetchUserByEmail(email: email) { result in
            switch result {
            case .success(let user):
                self.doctor = user
                self.loadPatients()
            case .failure(let err):
                self.errorMessage = err.localizedDescription
            }
        }
    }

    private func loadPatients() {
        let loader = patientMode == "today"
            ? DoctorPatientService.shared.getMyPatientsToday
            : DoctorPatientService.shared.getMyPatients

        loader { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let users):
                    self.patients = users
                case .failure(let err):
                    self.errorMessage = err.localizedDescription
                }
            }
        }
    }

    private func loadPrescriptions() {
        guard let doctorId = doctor?.id else { return }
        DoctorPrescriptionService.shared.getPrescriptionsByDoctor(doctorId: doctorId) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let list):
                    self.prescriptions = list.filter { $0.patient.id == self.selectedPatientId }
                case .failure(let error):
                    self.errorMessage = error.localizedDescription
                }
            }
        }
    }

    private func createPrescription() {
        guard let patientId = selectedPatientId else { return }
        DoctorPrescriptionService.shared.createPrescription(patientId: patientId, medications: medications, description: description) { result in
            DispatchQueue.main.async {
                switch result {
                case .success:
                    self.medications = ""
                    self.description = ""
                    self.showList = true
                    self.loadPrescriptions()
                case .failure(let err):
                    self.errorMessage = err.localizedDescription
                }
            }
        }
    }
}
