
import Foundation

struct DoctorAppointment: Identifiable, Decodable {
    let id: Int
    let date: String
    let time: String
    let clinic: String
    let status: String
    let description: String?
    let patient: PatientSummary
}

struct PatientSummary: Decodable {
    let id: Int
    let name: String
    let surname: String
}
