import Foundation

struct DoctorPatientStats: Identifiable {
    let id: Int
    let name: String
    let surname: String
    let email: String
    let phoneNumber: String
    let birthDate: String?
    let bloodType: String?

    var appointmentCount: Int = 0
    var prescriptionCount: Int = 0
    var testResultCount: Int = 0
    var historyCount: Int = 0
    var reportCount: Int = 0
}
