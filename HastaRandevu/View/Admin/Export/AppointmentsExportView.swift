import SwiftUI

struct AppointmentsExportView: View {
    @State private var appointments: [Appointments] = []
    @State private var message: String?
    
    var body: some View {
        VStack(spacing: 12) {
            Text("📅 Randevu Verileri").font(.title2).bold()
            
            if appointments.isEmpty {
                ProgressView("Veriler getiriliyor...")
            } else {
                Text("✅ \(appointments.count) veri listeleniyor.")
               /* ScrollView(.horizontal) {
                    Table(appointments, id: \Appointments.id) {
                        TableColumn("ID") { Text("\($0.id)") }
                        TableColumn("Hasta") {
                            Text("\($0.patient?.name ?? "-") \($0.patient?.surname ?? "")")
                        }
                        TableColumn("Doktor") {
                            Text("\($0.doctor?.name ?? "-") \($0.doctor?.surname ?? "")")
                        }
                        TableColumn("Klinik") {
                            Text($0.clinic.name ?? "-")
                        }
                        TableColumn("Tarih") {
                            Text($0.date)
                        }
                        TableColumn("Saat") {
                            Text($0.time)
                        }
                        TableColumn("Durum") {
                            Text($0.status)
                        }
                        TableColumn("Açıklama") {
                            Text($0.description ?? "-")
                        }
                    }
                    .frame(minHeight: 300)
                }
*/

                Button("⬇️ CSV Olarak İndir") {
                    ExportService.shared.exportAppointments { result in
                        switch result {
                        case .success(let file): message = "📥 \(file.lastPathComponent) indirildi."
                        case .failure: message = "❌ İndirme başarısız."
                        }
                    }
                }
                .buttonStyle(.borderedProminent)
                
                if let message { Text(message).font(.caption).foregroundColor(.gray) }
            }
        }
        .padding()
        .onAppear(perform: loadAppointments)
        .navigationTitle("Randevu İhracı")
    }
    
    private func loadAppointments() {
        print("🔍 loadAppointments çağrıldı.")
        
        AppointmentService.shared.getAllAppointments { result in
            switch result {
            case .success(let list):
                print("✅ \(list.count) randevu çekildi.")
                for appointment in list {
                    print("📌 ID: \(appointment.id), Hasta: \(appointment.patient?.name ?? "YOK")")
                }
                DispatchQueue.main.async {
                    self.appointments = list
                }
                
            case .failure(let error):
                print("❌ Hata oluştu: \(error.localizedDescription)")
                DispatchQueue.main.async {
                    self.message = "Veriler getirilemedi."
                }
            }
        }
    }
}
