import Foundation
import Alamofire

class DoctorPatientHistoryService {
    static let shared = DoctorPatientHistoryService()
    private init() {}

    private let baseURL = "\(AppConfig.baseUrl)/hastarandevu/patient-history"

    private var headers: HTTPHeaders? {
        if let token = UserDefaults.standard.string(forKey: "jwtToken") {
            return ["Authorization": "Bearer \(token)"]
        }
        return nil
    }

    func getHistoriesByPatientId(_ patientId: Int, completion: @escaping (Result<[DoctorPatientHistory], Error>) -> Void) {
        let url = "\(baseURL)/patient/\(patientId)"
        AF.request(url, headers: headers)
            .validate()
            .responseDecodable(of: [DoctorPatientHistory].self) { response in
                switch response.result {
                case .success(let data): completion(.success(data))
                case .failure(let error): completion(.failure(error))
                }
            }
    }


    func createHistory(_ request: DoctorPatientHistoryRequest, completion: @escaping (Result<Void, Error>) -> Void) {
        AF.request(baseURL, method: .post, parameters: request, encoder: JSONParameterEncoder.default, headers: headers)
            .validate()
            .response { response in
                switch response.result {
                case .success: completion(.success(()))
                case .failure(let error): completion(.failure(error))
                }
            }
    }
    func getHistoriesByDoctorId(_ doctorId: Int, completion: @escaping (Result<[DoctorPatientHistory], Error>) -> Void) {
        let url = "\(baseURL)/doctor/\(doctorId)"
        AF.request(url, headers: headers)
            .validate()
            .responseDecodable(of: [DoctorPatientHistory].self) { response in
                switch response.result {
                case .success(let data): completion(.success(data))
                case .failure(let error): completion(.failure(error))
                }
            }
    }

}
