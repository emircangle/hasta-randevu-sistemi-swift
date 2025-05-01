import Foundation
import Alamofire

class ComplaintService {
    static let shared = ComplaintService()
    private init() {}

    private let baseURL = "\(AppConfig.baseUrl)/hastarandevu/complaints"

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
    func getComplaintsByPatientId(patientId: Int, completion: @escaping (Result<[Complaint], Error>) -> Void) {
        let url = "\(baseURL)/user/\(patientId)"
        
        AF.request(url, headers: headers)
            .validate()
            .responseData { response in
                switch response.result {
                case .success(let data):
                    // 1️⃣ JSON verisini debug için yazdıralım:
                    if let jsonString = String(data: data, encoding: .utf8) {
                        print("📦 Gelen JSON Verisi:\n\(jsonString)")
                    }

                    // 2️⃣ Decode etmeye çalış:
                    do {
                        let decoded = try JSONDecoder().decode([Complaint].self, from: data)
                        completion(.success(decoded))
                    } catch {
                        print("❌ Decode Hatası: \(error)")
                        completion(.failure(error))
                    }

                case .failure(let error):
                    print("❌ Network Hatası: \(error)")
                    completion(.failure(error))
                }
            }
    }

}
