import Foundation
import Alamofire

class DoctorTestResultService {
    static let shared = DoctorTestResultService()
    private init() {}

    private let baseURL = "\(AppConfig.baseUrl)/hastarandevu/test-result"

    private var headers: HTTPHeaders? {
        if let token = UserDefaults.standard.string(forKey: "jwtToken") {
            return ["Authorization": "Bearer \(token)"]
        }
        return nil
    }

    func getTestResultsByPatientId(patientId: Int, completion: @escaping (Result<[TestResult], Error>) -> Void) {
        let url = "\(baseURL)/patient/\(patientId)"
        AF.request(url, headers: headers)
            .validate()
            .responseDecodable(of: [TestResult].self) { response in
                switch response.result {
                case .success(let data):
                    completion(.success(data))
                case .failure(let afError):
                    completion(.failure(afError as Error)) // ✅ Burada dönüşüm yapıldı
                }
            }
    }


    func createTestResult(request: TestResultRequest, completion: @escaping (Result<Void, Error>) -> Void) {
        AF.request(baseURL,
                   method: .post,
                   parameters: request,
                   encoder: JSONParameterEncoder.default,
                   headers: headers)
        .validate()
        .response { response in
            if let error = response.error {
                completion(.failure(error))
            } else {
                completion(.success(()))
            }
        }
    }
    func getTestResultsByDoctorId(doctorId: Int, completion: @escaping (Result<[TestResult], Error>) -> Void) {
        let url = "\(baseURL)/doctor/\(doctorId)"
        AF.request(url, headers: headers)
            .validate()
            .responseDecodable(of: [TestResult].self) { response in
                switch response.result {
                case .success(let data):
                    completion(.success(data))
                case .failure(let error):
                    completion(.failure(error))
                }
            }
    }

}
