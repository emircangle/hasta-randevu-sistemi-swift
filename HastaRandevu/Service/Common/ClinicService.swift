import Foundation
import Alamofire

class ClinicService {
    static let shared = ClinicService()
    private init() {}

    private let baseURL = "\(AppConfig.baseUrl)/hastarandevu/clinics"

    private var headers: HTTPHeaders? {
        if let token = UserDefaults.standard.string(forKey: "jwtToken") {
            return ["Authorization": "Bearer \(token)"]
        }
        return nil
    }

    func getAllClinics(completion: @escaping (Result<[Clinic], Error>) -> Void) {
        AF.request(baseURL, headers: headers)
            .validate()
            .responseDecodable(of: [Clinic].self) { response in
                switch response.result {
                case .success(let clinics):
                    completion(.success(clinics))
                case .failure(let error):
                    completion(.failure(error))
                }
            }
    }
    func getDoctorsByClinicId(clinicId: Int, completion: @escaping (Result<[User], Error>) -> Void) {
            let url = "\(baseURL)/\(clinicId)/doctors"
            AF.request(url, headers: headers)
                .validate()
                .responseDecodable(of: [User].self) { response in
                    completion(response.result.mapError { $0 as Error })
                }
        }
}
