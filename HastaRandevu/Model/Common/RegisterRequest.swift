import Foundation

struct RegisterRequest: Codable {
    let name: String
    let surname: String
    let email: String
    let password: String
    let phoneNumber: String
    let gender: String
    let birthDate: String
    let bloodType: String?
    let chronicDiseases: String
}

