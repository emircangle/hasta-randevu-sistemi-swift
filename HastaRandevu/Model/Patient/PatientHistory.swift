import Foundation

struct PatientHistory: Identifiable, Decodable {
    let id: Int
    let date: String
    let diagnosis: String
    let treatment: String
    let notes: String?
    let patient: PatientReference
    let doctor: DoctorReference?

}
