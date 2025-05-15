import SwiftUI

struct DoctorAppointmentsView: View {
    @State private var appointments: [DoctorAppointment] = []
    @State private var isLoading = true
    @State private var errorMessage: String?

    var body: some View {
        NavigationView {
            VStack {
                if isLoading {
                    ProgressView("Yükleniyor...")
                } else if let errorMessage = errorMessage {
                    Text("❌ Hata: \(errorMessage)").foregroundColor(.red)
                } else if appointments.isEmpty {
                    Text("Henüz randevunuz bulunmamaktadır.").foregroundColor(.gray)
                } else {
                    List(appointments) { appointment in
                        VStack(alignment: .leading, spacing: 4) {
                            Text("👤 Hasta: \(appointment.patient.name) \(appointment.patient.surname)")
                            Text("📅 Tarih: \(appointment.date)")
                            Text("⏰ Saat: \(appointment.time)")
                            Text("🏥 Klinik: \(appointment.clinic.name)")
                            Text("📝 Açıklama: \(appointment.description ?? "-")")
                            Text("📌 Durum: \(appointment.status)")
                        }
                        .padding(.vertical, 4)
                    }
                }
            }
            .navigationTitle("Gelen Randevularım")
            .onAppear(perform: loadAppointments)
        }
    }

    private func loadAppointments() {
        guard let email = TokenUtil.getEmailFromToken() else {
            errorMessage = "Token'dan email okunamadı."
            return
        }

        UserService.shared.fetchUserByEmail(email: email) { result in
            switch result {
            case .success(let user):
                DoctorService.shared.getAppointmentsByDoctor(doctorId: user.id) { result in
                    DispatchQueue.main.async {
                        isLoading = false
                        switch result {
                        case .success(let data): appointments = data
                        case .failure(let error): errorMessage = error.localizedDescription
                        }
                    }
                }

            case .failure(let error):
                DispatchQueue.main.async {
                    isLoading = false
                    errorMessage = error.localizedDescription
                }
            }
        }
    }
}
