import Foundation
import Alamofire

class AIService {
    static let shared = AIService()
    private init() {}

    private let baseURL = "http://localhost:8080/hastarandevu/ai/analyze"

    func analyzeComplaint(_ complaintText: String, completion: @escaping (Result<String, Error>) -> Void) {
        guard let token = UserDefaults.standard.string(forKey: "jwtToken") else {
            let error = NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Token bulunamadı"])
            completion(.failure(error))
            return
        }

        let headers: HTTPHeaders = [
            "Authorization": "Bearer \(token)",
            "Content-Type": "application/json"
        ]

        let parameters = ["complaintText": complaintText]

        AF.request(baseURL,
                   method: .post,
                   parameters: parameters,
                   encoding: JSONEncoding.default,
                   headers: headers)
        .validate()
        .responseString { response in
            switch response.result {
            case .success(let responseString):
                completion(.success(responseString))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
}
