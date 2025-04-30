import Foundation

struct PatientReport: Identifiable, Decodable {
    let id: Int
    let reportType: String
    let reportDate: String
    let fileUrl: String
    let doctor: DoctorReference
    let patient: PatientReference
}
