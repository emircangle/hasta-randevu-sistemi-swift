import Foundation

struct Complaint: Codable, Identifiable {
    let id: Int
    let subject: String          // 🔁 title yerine subject
    let content: String          // 🔁 description yerine content
    let createdAt: String        // 🔁 date yerine createdAt
    let user: PatientReference   // 🔁 patient yerine user
    let adminNote: String?
    let status: String
}

