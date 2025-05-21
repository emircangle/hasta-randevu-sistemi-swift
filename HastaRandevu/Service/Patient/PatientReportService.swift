import Foundation
import Alamofire

class PatientReportService {
    static let shared = PatientReportService()
    private init() {}

    private let baseURL = "\(AppConfig.baseUrl)/hastarandevu/patient-report"

    private var headers: HTTPHeaders? {
        if let token = UserDefaults.standard.string(forKey: "jwtToken") {
            return ["Authorization": "Bearer \(token)"]
        }
        return nil
    }

    func getReportsByPatientId(_ id: Int, completion: @escaping (Result<[PatientReport], Error>) -> Void) {
        let url = "\(baseURL)/patient/\(id)"
        AF.request(url, headers: headers)
            .validate()
            .responseDecodable(of: [PatientReport].self) { response in
                completion(response.result.mapError { $0 as Error })
            }
    }

    func getReportsByPatientAndPeriod(id: Int, period: String, completion: @escaping (Result<[PatientReport], Error>) -> Void) {
        let url = "\(baseURL)/patient/\(id)/filter?period=\(period)"
        AF.request(url, headers: headers)
            .validate()
            .responseDecodable(of: [PatientReport].self) { response in
                completion(response.result.mapError { $0 as Error })
            }
    }
    func getAllReports(completion: @escaping (Result<[PatientReport], Error>) -> Void) {
        AF.request(baseURL, headers: headers)
            .validate()
            .responseDecodable(of: [PatientReport].self) { response in
                switch response.result {
                case .success(let reports):
                    completion(.success(reports))
                case .failure(let error):
                    completion(.failure(error))
                }
            }
    }

}
