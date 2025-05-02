
import Foundation

struct TestResultRequest: Encodable {
    var patient: PatientReference
    var testName: String
    var testType: String
    var result: String
    var doctorComment: String?
    var testDate: String
}
