import Foundation

struct PatientReportRequest: Encodable {
    let patient: PatientReference
    let reportType: String
    let fileUrl: String
}
