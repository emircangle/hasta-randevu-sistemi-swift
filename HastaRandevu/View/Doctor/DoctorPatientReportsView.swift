import SwiftUI

struct DoctorPatientReportsView: View {
    @State private var patients: [User] = []
    @State private var selectedPatientId: Int? = nil
    @State private var reports: [PatientReport] = []

    @State private var reportType = ""
    @State private var fileUrl = ""
    @State private var editingReportId: Int? = nil

    @State private var patientMode: String = "today"
    @State private var mode: String = "" // "", "add", "list"
    @State private var isLoading = false
    @State private var errorMessage: String?

    var body: some View {
        NavigationStack {
            VStack(spacing: 16) {
                // Hasta türü
                HStack {
                    Button("Randevulu Hastalar") {
                        patientMode = "today"
                        selectedPatientId = nil
                        mode = ""
                        fetchPatients()
                    }.disabled(patientMode == "today")

                    Button("Randevusuz Hastalar") {
                        patientMode = "all"
                        selectedPatientId = nil
                        mode = ""
                        fetchPatients()
                    }.disabled(patientMode == "all")
                }

                // Hasta seçimi
                Picker("Hasta Seçin", selection: Binding(
                    get: { selectedPatientId ?? -1 },
                    set: { selectedPatientId = $0 == -1 ? nil : $0 })
                ) {
                    Text("-- Hasta Seçin --").tag(-1)
                    ForEach(patients, id: \.id) { p in
                        Text("\(p.name) \(p.surname)").tag(p.id)
                    }
                }
                .pickerStyle(.menu)

                if let _ = selectedPatientId {
                    if mode.isEmpty {
                        if patientMode == "today" {
                            Button("Rapor Ekle") {
                                mode = "add"
                            }
                        }
                        Button("Raporları Gör") {
                            fetchReports()
                            mode = "list"
                        }
                    } else if mode == "add" {
                        VStack(spacing: 8) {
                            TextField("Rapor Türü", text: $reportType)
                                .textFieldStyle(.roundedBorder)

                            TextField("Dosya Bağlantısı", text: $fileUrl)
                                .textFieldStyle(.roundedBorder)

                            Button(editingReportId == nil ? "Kaydet" : "Güncelle") {
                                createOrUpdateReport()
                            }
                        }
                    } else if mode == "list" {
                        if isLoading {
                            ProgressView()
                        } else if reports.isEmpty {
                            Text("Rapor bulunamadı.")
                                .foregroundColor(.gray)
                        } else {
                            List(reports) { report in
                                VStack(alignment: .leading) {
                                    Text("📄 \(report.reportType)")
                                    Text("📎 \(report.fileUrl)")
                                    Text("📅 \(report.reportDate)")
                                    HStack {
                                        Button("✏️ Düzenle") {
                                            reportType = report.reportType
                                            fileUrl = report.fileUrl
                                            editingReportId = report.id
                                            mode = "add"
                                        }
                                        Button("🗑️ Sil") {
                                            deleteReport(id: report.id)
                                        }
                                    }
                                }
                            }
                        }
                    }

                    Button("← Geri") {
                        mode = ""
                        selectedPatientId = nil
                        reports = []
                        resetForm()
                    }
                }

                Spacer()
            }
            .padding()
            .navigationTitle("Hasta Raporları")
            .onAppear(perform: fetchPatients)
        }
    }

    // MARK: - Servis Fonksiyonları

    private func fetchPatients() {
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

    private func fetchReports() {
        guard let patientId = selectedPatientId else { return }
        isLoading = true
        DoctorPatientReportService.shared.getReportsByPatientId(patientId) { result in
            DispatchQueue.main.async {
                isLoading = false
                switch result {
                case .success(let data): reports = data
                case .failure(let err): errorMessage = err.localizedDescription
                }
            }
        }
    }

    private func createOrUpdateReport() {
        guard let patientId = selectedPatientId else { return }

        let request = PatientReportRequest(
            patient: PatientReference(id: patientId),
            reportType: reportType,
            fileUrl: fileUrl
        )

        if let id = editingReportId {
            DoctorPatientReportService.shared.updateReport(id: id, updatedData: request) { _ in
                mode = ""
                fetchReports()
                resetForm()
            }
        } else {
            DoctorPatientReportService.shared.createReport(request) { _ in
                mode = ""
                fetchReports()
                resetForm()
            }
        }

    }

    private func deleteReport(id: Int) {
        DoctorPatientReportService.shared.deleteReport(id: id) { _ in
            fetchReports()
        }
    }

    private func resetForm() {
        reportType = ""
        fileUrl = ""
        editingReportId = nil
    }
}
