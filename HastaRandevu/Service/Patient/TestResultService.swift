import Foundation
import Alamofire

class TestResultService {
    static let shared = TestResultService()
    private init() {}

    private let baseURL = "\(AppConfig.baseUrl)/hastarandevu/test-result"

    private var headers: HTTPHeaders? {
        if let token = UserDefaults.standard.string(forKey: "jwtToken") {
            return ["Authorization": "Bearer \(token)"]
        }
        return nil
    }

    func getTestResultsByPatientId(_ patientId: Int, completion: @escaping (Result<[TestResult], Error>) -> Void) {
        let url = "\(baseURL)/patient/\(patientId)"
        AF.request(url, headers: headers)
            .validate()
            .responseDecodable(of: [TestResult].self) { response in
                switch response.result {
                case .success(let results):
                    completion(.success(results))
                case .failure(let error):
                    completion(.failure(error))
                }
            }
    }

    func getTestResultsByPatientAndPeriod(patientId: Int, period: String, completion: @escaping (Result<[TestResult], Error>) -> Void) {
        let url = "\(baseURL)/patient/\(patientId)/filter?period=\(period)"
        AF.request(url, headers: headers)
            .validate()
            .responseDecodable(of: [TestResult].self) { response in
                switch response.result {
                case .success(let results):
                    completion(.success(results))
                case .failure(let error):
                    completion(.failure(error))
                }
            }
    }
    func getAllTestResults(completion: @escaping (Result<[TestResult], Error>) -> Void) {
        AF.request(baseURL, headers: headers)
            .validate()
            .responseDecodable(of: [TestResult].self) { response in
                switch response.result {
                case .success(let results):
                    completion(.success(results))
                case .failure(let error):
                    completion(.failure(error))
                }
            }
    }

}
