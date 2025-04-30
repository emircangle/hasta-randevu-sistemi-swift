import SwiftUI

struct MyAppointmentsView: View {
    @State private var appointments: [Appointments] = []
    @State private var filteredAppointments: [Appointments] = []
    @State private var filterOption = "ALL"
    @State private var startDate: Date = Date()
    @State private var endDate: Date = Date()
    @State private var patientId: Int?
    @State private var errorMessage: String?

    private let filterOptions = ["ALL", "ACTIVE", "CANCELED", "LAST_7_DAYS", "LAST_30_DAYS"]

    var body: some View {
        VStack {
            Text("🗂️ Randevularım")
                .font(.title)
                .bold()

            Picker("Filtre", selection: $filterOption) {
                ForEach(filterOptions, id: \.self) {
                    Text($0)
                }
            }
            .pickerStyle(SegmentedPickerStyle())
            .padding()

            HStack {
                DatePicker("Başlangıç", selection: $startDate, displayedComponents: .date)
                DatePicker("Bitiş", selection: $endDate, displayedComponents: .date)
            }
            .padding(.horizontal)

            Text("🔍 Gösterilen: \(filteredAppointments.count) randevu")
                .font(.subheadline)
                .padding(.top, 8)

            List {
                ForEach(filteredAppointments) { app in
                    VStack(alignment: .leading, spacing: 5) {
                        Text("📍 Klinik: \(app.clinic)")
                        Text("📅 Tarih: \(app.date)")
                        Text("⏰ Saat: \(app.time.prefix(5))")
                        Text("📌 Durum: \(app.status)")
                        if let desc = app.description {
                            Text("📝 Açıklama: \(desc)")
                        }

                        if app.status == "AKTIF" {
                            Button("❌ İptal Et") {
                                cancelAppointment(id: app.id)
                            }
                            .foregroundColor(.red)
                        }
                    }
                    .padding(.vertical, 4)
                }
            }

            if let errorMessage = errorMessage {
                Text(errorMessage).foregroundColor(.red)
            }

        }
        .padding()
        .onAppear {
            self.startDate = Calendar.current.date(byAdding: .day, value: -365, to: Date())!
            self.endDate = Calendar.current.date(byAdding: .day, value: 30, to: Date())!
            fetchCurrentUser()
        }
        .onChange(of: filterOption) { _ in applyFilter() }
        .onChange(of: startDate) { _ in applyFilter() }
        .onChange(of: endDate) { _ in applyFilter() }
    }

    private func fetchCurrentUser() {
        if let email = TokenUtil.getEmailFromToken() {
            UserService.shared.fetchUserByEmail(email: email) { result in
                switch result {
                case .success(let user):
                    self.patientId = user.id
                    fetchAppointments(for: user.id)
                case .failure(let error):
                    self.errorMessage = "Kullanıcı alınamadı: \(error.localizedDescription)"
                    print("❌ Kullanıcı alınamadı: \(error.localizedDescription)")
                }
            }
        } else {
            print("❌ Token'dan email çözülemedi.")
        }
    }

    private func fetchAppointments(for id: Int) {
        AppointmentService.shared.getAppointmentsByPatientId(id) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let data):
                    self.appointments = data.sorted { $0.date > $1.date }
                    self.applyFilter()
                case .failure(let error):
                    self.errorMessage = "Randevular alınamadı: \(error.localizedDescription)"
                    print("❌ Randevu verisi alınamadı: \(error.localizedDescription)")
                }
            }
        }
    }

    private func applyFilter() {
        var result = appointments

        switch filterOption {
        case "ACTIVE":
            result = result.filter { $0.status == "AKTIF" }
        case "CANCELED":
            result = result.filter { $0.status == "IPTAL_EDILDI" }
        case "LAST_7_DAYS":
            result = result.filter { isWithinLastDays(dateStr: $0.date, days: 7) }
        case "LAST_30_DAYS":
            result = result.filter { isWithinLastDays(dateStr: $0.date, days: 30) }
        default:
            break
        }

        result = result.filter {
            if let date = DateFormatter.dateOnly.date(from: $0.date) {
                return date >= startDate && date <= endDate
            }
            return false
        }

        self.filteredAppointments = result
    }

    private func isWithinLastDays(dateStr: String, days: Int) -> Bool {
        guard let date = DateFormatter.dateOnly.date(from: dateStr) else { return false }
        let now = Date()
        return date >= Calendar.current.date(byAdding: .day, value: -days, to: now)!
    }

    private func cancelAppointment(id: Int) {
        print("🛑 İptal isteği gönderiliyor: Randevu ID \(id)")
        AppointmentService.shared.cancelAppointment(id) { result in
            DispatchQueue.main.async {
                switch result {
                case .success:
                    print("✅ Randevu başarıyla iptal edildi.")
                    if let patientId = self.patientId {
                        fetchAppointments(for: patientId)
                    }
                case .failure(let error):
                    self.errorMessage = "İptal edilemedi: \(error.localizedDescription)"
                    print("❌ İptal hatası: \(error.localizedDescription)")
                }
            }
        }
    }
}

extension DateFormatter {
    static var dateOnly: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter
    }
}
