import Foundation

struct AppointmentRequest: Codable {
    var clinicId: Int
    var date: String
    var time: String
    var description: String?
    var doctor: DoctorReference    // ✅ DOĞRU
    var patient: PatientReference  // ✅ DOĞRU
}
