import Foundation
import Alamofire

class DoctorPatientService {
    static let shared = DoctorPatientService()
    private init() {}

    private let baseURL = "\(AppConfig.baseUrl)/hastarandevu/doctorPatients"

    private var headers: HTTPHeaders? {
        if let token = UserDefaults.standard.string(forKey: "jwtToken") {
            return ["Authorization": "Bearer \(token)"]
        }
        return nil
    }

    func getMyPatientsToday(completion: @escaping (Result<[User], Error>) -> Void) {
        let url = "\(baseURL)/my-patients-today"
        AF.request(url, headers: headers)
            .validate()
            .responseDecodable(of: [User].self) { response in
                switch response.result {
                case .success(let data): completion(.success(data))
                case .failure(let error): completion(.failure(error))
                }
            }
    }

    func getMyPatients(completion: @escaping (Result<[User], Error>) -> Void) {
        let url = "\(baseURL)/my-patients"
        AF.request(url, headers: headers)
            .validate()
            .responseDecodable(of: [User].self) { response in
                switch response.result {
                case .success(let data): completion(.success(data))
                case .failure(let error): completion(.failure(error))
                }
            }
    }
}
