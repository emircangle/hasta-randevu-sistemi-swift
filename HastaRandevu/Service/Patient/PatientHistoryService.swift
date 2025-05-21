import Foundation
import Alamofire

class PatientHistoryService {
    static let shared = PatientHistoryService()
    private init() {}

    private let baseURL = "\(AppConfig.baseUrl)/hastarandevu/patient-history"

    private var headers: HTTPHeaders? {
        if let token = UserDefaults.standard.string(forKey: "jwtToken") {
            return ["Authorization": "Bearer \(token)"]
        }
        return nil
    }

    func getHistoriesByPatientId(_ id: Int, completion: @escaping (Result<[PatientHistory], Error>) -> Void) {
        let url = "\(baseURL)/patient/\(id)"
        AF.request(url, headers: headers)
            .validate()
            .responseDecodable(of: [PatientHistory].self) { response in
                completion(response.result.mapError { $0 as Error })
            }
    }

    func getHistoriesByPeriod(patientId: Int, period: String, completion: @escaping (Result<[PatientHistory], Error>) -> Void) {
        let url = "\(baseURL)/patient/\(patientId)/filter?period=\(period)"
        AF.request(url, headers: headers)
            .validate()
            .responseDecodable(of: [PatientHistory].self) { response in
                completion(response.result.mapError { $0 as Error })
            }
    }

    func searchByDiagnosis(keyword: String, completion: @escaping (Result<[PatientHistory], Error>) -> Void) {
        let url = "\(baseURL)/search/diagnosis?keyword=\(keyword)"
        AF.request(url, headers: headers)
            .validate()
            .responseDecodable(of: [PatientHistory].self) { response in
                completion(response.result.mapError { $0 as Error })
            }
    }

    func searchByTreatment(keyword: String, completion: @escaping (Result<[PatientHistory], Error>) -> Void) {
        let url = "\(baseURL)/search/treatment?keyword=\(keyword)"
        AF.request(url, headers: headers)
            .validate()
            .responseDecodable(of: [PatientHistory].self) { response in
                completion(response.result.mapError { $0 as Error })
            }
    }
    func getAllHistories(completion: @escaping (Result<[PatientHistory], Error>) -> Void) {
        AF.request(baseURL, headers: headers)
            .validate()
            .responseDecodable(of: [PatientHistory].self) { response in
                switch response.result {
                case .success(let histories):
                    completion(.success(histories))
                case .failure(let error):
                    completion(.failure(error))
                }
            }
    }

}
