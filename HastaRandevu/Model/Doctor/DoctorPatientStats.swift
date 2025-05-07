import Foundation

struct DoctorPatientStats: Identifiable, Decodable {
    let id: Int
    let name: String
    let surname: String
    let email: String
    let phoneNumber: String
    let birthDate: String?
    let bloodType: String?

    let appointmentCount: Int
    let prescriptionCount: Int
    let testResultCount: Int
    let historyCount: Int
    let reportCount: Int
}
