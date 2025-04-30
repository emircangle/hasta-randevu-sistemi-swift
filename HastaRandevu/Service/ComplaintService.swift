import Foundation
import Alamofire

class ComplaintService {
    static let shared = ComplaintService()
    private init() {}

    private let baseURL = "http://localhost:8080/hastarandevu/complaints"

    private var headers: HTTPHeaders? {
        if let token = UserDefaults.standard.string(forKey: "jwtToken") {
            return ["Authorization": "Bearer \(token)"]
        }
        return nil
    }

    func createComplaint(_ request: ComplaintRequest, completion: @escaping (Result<Void, Error>) -> Void) {
        AF.request(baseURL, method: .post, parameters: request, encoder: JSONParameterEncoder.default, headers: headers)
            .validate()
            .response { response in
                switch response.result {
                case .success:
                    completion(.success(()))
                case .failure(let error):
                    completion(.failure(error))
                }
            }
    }
}
