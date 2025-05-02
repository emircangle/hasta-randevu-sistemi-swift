import Foundation

struct PrescriptionRequest: Encodable {
    let prescriptionCode: String
    let date: String
    let medications: String
    let description: String?
    let doctor: DoctorReference
    let patient: PatientReference
}
