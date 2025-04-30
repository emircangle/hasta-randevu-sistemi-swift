import SwiftUI

struct MyPrescriptionsView: View {
    @State private var prescriptions: [Prescription] = []
    @State private var filteredPrescriptions: [Prescription] = []
    @State private var selectedPeriod = "all"
    @State private var keyword = ""
    @State private var patientId: Int?
    @State private var errorMessage: String?

    private let periodOptions = ["all", "day", "week", "month", "year"]

    var body: some View {
        VStack {
            Text("📄 Reçetelerim")
                .font(.title)
                .bold()
                .padding(.top)

            Picker("Zaman Filtresi", selection: $selectedPeriod) {
                ForEach(periodOptions, id: \.self) { option in
                    Text(labelForPeriod(option))
                }
            }
            .pickerStyle(SegmentedPickerStyle())
            .padding(.horizontal)
            .onChange(of: selectedPeriod) { _ in fetchPrescriptions() }

            TextField("Açıklamada ara...", text: $keyword)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding(.horizontal)
                .onChange(of: keyword) { _ in search() }

            if !filteredPrescriptions.isEmpty {
                List(filteredPrescriptions, id: \.id) { p in
                    VStack(alignment: .leading, spacing: 5) {
                        Text("📋 Kod: \(p.prescriptionCode)")
                        Text("📅 Tarih: \(p.date)")
                        Text("👨‍⚕️ Doktor: \((p.doctor.name ?? "").prefix(1)). \(p.doctor.surname ?? "")")
                        Text("💊 İlaçlar: \(p.medications)")
                        if let desc = p.description {
                            Text("📝 Açıklama: \(desc)")
                        }
                    }
                    .padding(.vertical, 4)
                }
            } else if errorMessage == nil {
                Text("Gösterilecek reçete bulunamadı.")
                    .foregroundColor(.gray)
                    .padding()
            }

            if let error = errorMessage {
                Text("⚠️ \(error)")
                    .foregroundColor(.red)
                    .padding(.top, 8)
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
                    self.fetchPrescriptions()
                case .failure(let error):
                    self.errorMessage = "Kullanıcı alınamadı: \(error.localizedDescription)"
                }
            }
        }
    }

    private func fetchPrescriptions() {
        guard let id = patientId else { return }
        errorMessage = nil

        let fetchFunction: (@escaping (Result<[Prescription], Error>) -> Void) -> Void = selectedPeriod == "all"
            ? { PrescriptionService.shared.getPrescriptionsByPatient(patientId: id, completion: $0) }
            : { PrescriptionService.shared.getPrescriptionsByPeriod(patientId: id, period: selectedPeriod, completion: $0) }

        fetchFunction { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let data):
                    self.prescriptions = data
                    self.filteredPrescriptions = data
                case .failure(let error):
                    self.errorMessage = "Reçeteler alınamadı: \(error.localizedDescription)"
                }
            }
        }
    }

    private func search() {
        guard !keyword.isEmpty else {
            filteredPrescriptions = prescriptions
            return
        }

        PrescriptionService.shared.searchPrescriptions(keyword: keyword) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let data):
                    self.filteredPrescriptions = data.filter { $0.patient.id == self.patientId }
                case .failure(let error):
                    self.errorMessage = "Arama başarısız: \(error.localizedDescription)"
                }
            }
        }
    }
}
