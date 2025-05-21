import SwiftUI
import Alamofire

struct ClinicFormSheet: View {
    var clinicToEdit: Clinic?

    @Environment(\.dismiss) private var dismiss

    @State private var name: String = ""
    @State private var description: String = ""

    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("Klinik Bilgileri")) {
                    TextField("Klinik Adı", text: $name)
                    TextField("Açıklama", text: $description)
                }

                Section {
                    Button(clinicToEdit == nil ? "Klinik Ekle" : "Klinik Güncelle") {
                        submitClinic()
                    }
                }
            }
            .navigationTitle(clinicToEdit == nil ? "Yeni Klinik" : "Klinik Güncelle")
            .navigationBarTitleDisplayMode(.inline)
            .onAppear {
                if let clinic = clinicToEdit {
                    name = clinic.name
                    description = clinic.description
                }
            }
        }
    }

    private func submitClinic() {
        let data = ["name": name, "description": description]

        if let clinic = clinicToEdit {
            AF.request("\(ClinicService.shared.baseURL)/\(clinic.id)",
                       method: .put,
                       parameters: data,
                       encoding: JSONEncoding.default,
                       headers: ClinicService.shared.headers)
            .validate()
            .response { _ in dismiss() }
        } else {
            AF.request(ClinicService.shared.baseURL,
                       method: .post,
                       parameters: data,
                       encoding: JSONEncoding.default,
                       headers: ClinicService.shared.headers)
            .validate()
            .response { _ in dismiss() }
        }
    }
}
