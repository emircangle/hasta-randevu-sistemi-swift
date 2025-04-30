import Foundation

struct Complaint: Codable, Identifiable {
    let id: Int
    let title: String
    let description: String
    let date: String
    let patient: PatientReference
}
