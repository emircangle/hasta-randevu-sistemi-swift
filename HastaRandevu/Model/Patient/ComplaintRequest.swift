

import Foundation

struct ComplaintRequest: Encodable {
    let subject: String
    let content: String
    let user: PatientReference
    let clinic: ClinicReference?
}

