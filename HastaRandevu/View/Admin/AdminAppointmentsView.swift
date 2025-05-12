import SwiftUI

struct AdminAppointmentsView: View {
    @State private var appointments: [Appointments] = []
    @State private var filteredAppointments: [Appointments] = []

    @State private var selectedPeriod = ""
    @State private var selectedStatus = ""
    @State private var keyword = ""

    var body: some View {
        NavigationStack {
            VStack(spacing: 12) {
                Text("\u{1F4C5} Randevu Yönetimi")
                    .font(.title2)
                    .bold()

                // Filtreler
                HStack {
                    Picker("Zaman", selection: $selectedPeriod) {
                        Text("Tümü").tag("")
                        Text("Son 1 Gün").tag("day")
                        Text("Son 1 Hafta").tag("week")
                        Text("Son 1 Ay").tag("month")
                        Text("Son 1 Yıl").tag("year")
                    }
                    .onChange(of: selectedPeriod) { _ in
                        filterByPeriod()
                    }

                    Picker("Durum", selection: $selectedStatus) {
                        Text("Tümü").tag("")
                        Text("Aktif").tag("AKTIF")
                        Text("İptal Edildi").tag("IPTAL_EDILDI")
                        Text("Geç Kalındı").tag("GEC_KALINDI")
                    }
                    .onChange(of: selectedStatus) { _ in
                        filterByStatus()
                    }
                }
                .padding(.horizontal)

                TextField("Açıklamada ara...", text: $keyword)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding(.horizontal)
                    .onChange(of: keyword) { _ in
                        applyKeywordFilter()
                    }

                List(filteredAppointments) { appointment in
                    VStack(alignment: .leading) {
                        Text("📅 Tarih: \(appointment.date) - \(appointment.time)").bold()
                        Text("Doktor: \(appointment.doctor?.name ?? "-") \(appointment.doctor?.surname ?? "-")")
                        Text("Hasta: \(appointment.patient?.name ?? "-") \(appointment.patient?.surname ?? "-")")
                        Text("🏥 Klinik: \(appointment.clinic)")
                        Text("📄 Açıklama: \(appointment.description ?? "-")")
                        Text("⚙️ Durum: \(appointment.status)")
                    }
                    .padding(6)
                }
            }
            .onAppear(perform: getAllAppointments)
            .navigationTitle("Tüm Randevular")
        }
    }

    private func getAllAppointments() {
        AppointmentService.shared.getAllAppointments { result in
            switch result {
            case .success(let list):
                appointments = list
                filteredAppointments = list
            case .failure:
                print("❌ Randevular getirilemedi")
            }
        }
    }

    private func filterByPeriod() {
        if selectedPeriod.isEmpty {
            getAllAppointments()
        } else {
            AppointmentService.shared.getAppointmentsByPeriod(selectedPeriod) { result in
                switch result {
                case .success(let list):
                    appointments = list
                    filterByStatus()
                case .failure:
                    print("❌ Zaman filtrelemesi başarısız")
                }
            }
        }
    }

    private func filterByStatus() {
        filteredAppointments = appointments.filter { appt in
            selectedStatus.isEmpty || appt.status == selectedStatus
        }
        applyKeywordFilter()
    }

    private func applyKeywordFilter() {
        guard !keyword.isEmpty else { return }
        filteredAppointments = filteredAppointments.filter { appt in
            (appt.description ?? "").lowercased().contains(keyword.lowercased())
        }
    }
}
