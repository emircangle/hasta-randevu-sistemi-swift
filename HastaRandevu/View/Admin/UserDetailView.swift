import SwiftUI

struct UserDetailView: View {
    let user: User

    var body: some View {
        Form {
            Section(header: Text("Genel Bilgiler")) {
                Text("👤 Ad: \(user.name)")
                Text("👤 Soyad: \(user.surname)")
                Text("✉️ Email: \(user.email)")
                Text("📞 Telefon: \(user.phoneNumber)")
                Text("🎯 Rol: \(user.role)")
                Text("🧬 Cinsiyet: \(user.gender)")
                Text("🎂 Doğum Tarihi: \(user.birthDate ?? "-")")
            }

            if user.role == "HASTA" {
                Section(header: Text("Hasta Bilgileri")) {
                    Text("🩸 Kan Grubu: \(user.bloodType ?? "-")")
                    Text("📋 Kronik Rahatsızlık: \(user.chronicDiseases ?? "-")")
                }
            }

            if user.role == "DOKTOR" {
                Section(header: Text("Doktor Bilgisi")) {
                    Text("🏥 Uzmanlık: \(user.specialization ?? "-")")
                }
            }
        }
        .navigationTitle("Kullanıcı Detayı")
    }
}
