import SwiftUI

struct MyReportsView: View {
    @State private var reports: [PatientReport] = []
    @State private var filteredReports: [PatientReport] = []
    @State private var selectedPeriod = "all"
    @State private var keyword = ""
    @State private var patientId: Int?
    @State private var errorMessage: String?

    private let periodOptions = ["all", "day", "week", "month", "year"]

    var body: some View {
        VStack {
            Text("📄 Raporlarım")
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
            .onChange(of: selectedPeriod) { _ in fetchReports() }

            TextField("Rapor türünde ara...", text: $keyword)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding(.horizontal)
                .onChange(of: keyword) { _ in applyKeyword() }

            if !filteredReports.isEmpty {
                List(filteredReports, id: \.id) { report in
                    VStack(alignment: .leading, spacing: 6) {
                        Text("📌 Tür: \(report.reportType)")
                        Text("📅 Tarih: \(report.reportDate)")
                        Text("👨‍⚕️ Doktor: \((report.doctor.name ?? "").prefix(1)) \(report.doctor.surname ?? "")")
                        Link("📎 Dosya: Görüntüle", destination: URL(string: report.fileUrl)!)
                    }
                    .padding(.vertical, 4)
                }
            } else if errorMessage == nil {
                Text("Hiç rapor bulunamadı.")
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
                    fetchReports()
                case .failure(let error):
                    self.errorMessage = "Kullanıcı alınamadı: \(error.localizedDescription)"
                }
            }
        }
    }

    private func fetchReports() {
        guard let id = patientId else { return }
        errorMessage = nil

        let service = PatientReportService.shared
        let handler: (Result<[PatientReport], Error>) -> Void = { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let data):
                    self.reports = data
                    self.applyKeyword()
                case .failure(let error):
                    self.errorMessage = "Raporlar alınamadı: \(error.localizedDescription)"
                }
            }
        }

        if selectedPeriod == "all" {
            service.getReportsByPatientId(id, completion: handler)
        } else {
            service.getReportsByPatientAndPeriod(id: id, period: selectedPeriod, completion: handler)
        }
    }

    private func applyKeyword() {
        if keyword.isEmpty {
            filteredReports = reports
        } else {
            filteredReports = reports.filter {
                $0.reportType.lowercased().contains(keyword.lowercased())
            }
        }
    }
}
