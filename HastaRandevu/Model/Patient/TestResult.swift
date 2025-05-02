import Foundation

struct TestResult: Identifiable, Decodable {
    let id: Int
    let testName: String
    let testDate: String // backend formatı "yyyy-MM-dd" varsayımıyla
    let testType: String
    let result: String
    let doctorComment: String?
    let patient: PatientReference
    let doctor: DoctorReference
}

