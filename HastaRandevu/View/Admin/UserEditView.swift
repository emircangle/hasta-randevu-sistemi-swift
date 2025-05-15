import SwiftUI

struct UserEditView: View {
    @Environment(\.dismiss) var dismiss

    @State var user: User
    let onSave: () -> Void

    @State private var clinics: [Clinic] = []
    @State private var selectedClinicId: Int?

    var body: some View {
        Form {
            Section(header: Text("Genel Bilgiler")) {
                TextField("Ad", text: $user.name)
                TextField("Soyad", text: $user.surname)
                TextField("Email", text: $user.email)
                TextField("Telefon", text: $user.phoneNumber)
                TextField("Doğum Tarihi", text: Binding(
                    get: { user.birthDate ?? "" },
                    set: { user.birthDate = $0 }
                ))

                Picker("Cinsiyet", selection: $user.gender) {
                    Text("ERKEK").tag("ERKEK")
                    Text("KADIN").tag("KADIN")
                    Text("BELIRTILMEMIS").tag("BELIRTILMEMIS")
                }
            }

            if user.role == "DOKTOR" {
                Section(header: Text("Doktor Bilgisi")) {
                    TextField("Uzmanlık", text: Binding(
                        get: { user.specialization ?? "" },
                        set: { user.specialization = $0 }
                    ))

                    Picker("Klinik", selection: Binding(
                        get: { selectedClinicId ?? user.clinic?.id },
                        set: { selectedClinicId = $0 }
                    )) {
                        Text("-- Seçiniz --").tag(nil as Int?)
                        ForEach(clinics, id: \.id) { clinic in
                            Text(clinic.name).tag(clinic.id as Int?)
                        }
                    }
                }
            }

            if user.role == "HASTA" {
                Section(header: Text("Hasta Bilgileri")) {
                    Picker("Kan Grubu", selection: Binding(
                        get: { user.bloodType ?? "" },
                        set: { user.bloodType = $0 }
                    )) {
                        ForEach(["ARH_POS", "ARH_NEG", "BRH_POS", "BRH_NEG", "ABRH_POS", "ABRH_NEG", "ORH_POS", "ORH_NEG"], id: \.self) {
                            Text($0)
                        }
                    }

                    TextField("Kronik Rahatsızlık", text: Binding(
                        get: { user.chronicDiseases ?? "" },
                        set: { user.chronicDiseases = $0 }
                    ))
                }
            }

            Section {
                Button("💾 Kaydet") {
                    if user.role == "DOKTOR", let selectedId = selectedClinicId {
                        user.clinic = clinics.first(where: { $0.id == selectedId })
                    }

                    UserService.shared.updateUser(user) { result in
                        switch result {
                        case .success:
                            onSave()
                            dismiss()
                        case .failure(let error):
                            print("Güncelleme hatası: \(error.localizedDescription)")
                        }
                    }
                }
            }
        }
        .navigationTitle("Kullanıcı Güncelle")
        .onAppear(perform: loadClinics)
    }

    private func loadClinics() {
        ClinicService.shared.getAllClinics { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let list):
                    clinics = list.filter { $0.isActive }
                    selectedClinicId = user.clinic?.id
                case .failure(let error):
                    print("Klinik verileri alınamadı: \(error.localizedDescription)")
                }
            }
        }
    }
}
