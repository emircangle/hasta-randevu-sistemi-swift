import Foundation

struct PatientReference: Codable {
    let id: Int
    let name: String?
    let surname: String?

    init(id: Int, name: String? = nil, surname: String? = nil) {
        self.id = id
        self.name = name
        self.surname = surname
    }
}
