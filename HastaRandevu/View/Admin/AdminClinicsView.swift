import SwiftUI

struct AdminClinicsView: View {
    @State private var clinics: [Clinic] = []
    @State private var showClinicForm = false
    @State private var clinicToEdit: Clinic?

    var body: some View {
        NavigationStack {
            VStack {
                List {
                    ForEach(clinics) { clinic in
                        VStack(alignment: .leading, spacing: 4) {
                            Text(clinic.name)
                                .font(.headline)
                            Text(clinic.description)
                                .font(.subheadline)
                                .foregroundColor(.gray)
                            Text(clinic.isActive ? "✅ Aktif" : "⛔️ Pasif")
                                .font(.caption)
                                .foregroundColor(clinic.isActive ? .green : .red)

                            HStack {
                                Button("✏️ Düzenle") {
                                    clinicToEdit = clinic
                                    showClinicForm = true
                                }
                                .buttonStyle(.bordered)

                                if clinic.isActive {
                                    Button("⛔️ Pasifleştir") {
                                        deactivateClinic(id: clinic.id)
                                    }
                                    .foregroundColor(.red)
                                } else {
                                    Button("🟢 Aktifleştir") {
                                        activateClinic(id: clinic.id)
                                    }
                                    .foregroundColor(.green)
                                }
                            }
                        }
                        .padding(.vertical, 4)
                    }
                }

                Button {
                    clinicToEdit = nil
                    showClinicForm = true
                } label: {
                    Label("Yeni Klinik Ekle", systemImage: "plus.circle")
                }
                .padding()
                .buttonStyle(.borderedProminent)
            }
            .navigationTitle("Klinik Yönetimi")
            .onAppear(perform: loadClinics)
            .sheet(isPresented: $showClinicForm, onDismiss: loadClinics) {
                ClinicFormSheet(clinicToEdit: clinicToEdit)
            }
        }
    }

    private func loadClinics() {
        ClinicService.shared.getAllClinics { result in
            switch result {
            case .success(let list):
                self.clinics = list
            case .failure(let error):
                print("❌ Klinikler getirilemedi:", error)
            }
        }
    }

    private func deactivateClinic(id: Int) {
        ClinicService.shared.deactivateClinic(id: id) { _ in loadClinics() }
    }

    private func activateClinic(id: Int) {
        ClinicService.shared.activateClinic(id: id) { _ in loadClinics() }
    }
}
