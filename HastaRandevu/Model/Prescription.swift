import Foundation

struct Prescription: Decodable, Identifiable {
    let id: Int
    var prescriptionCode: String
    var date: String
    var medications: String
    var description: String?
    var doctor: DoctorReference
    var patient: PatientReference
}
