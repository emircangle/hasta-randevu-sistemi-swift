import Foundation

struct DoctorPatientHistory: Identifiable, Decodable {
    let id: Int
    let title: String
    let description: String
    let date: String
    let doctor: DoctorReference
    let patient: PatientReference
}

struct DoctorPatientHistoryRequest: Encodable {
    let patient: PatientReference
    let title: String
    let description: String
    let date: String
}
