import Foundation
import Alamofire

class DoctorPrescriptionService {
    static let shared = DoctorPrescriptionService()
    private init() {}

    private let baseURL = "\(AppConfig.baseUrl)/hastarandevu/prescriptions"

    private var headers: HTTPHeaders? {
        if let token = UserDefaults.standard.string(forKey: "jwtToken") {
            return ["Authorization": "Bearer \(token)"]
        }
        return nil
    }

    func getPrescriptionsByDoctor(doctorId: Int, completion: @escaping (Result<[Prescription], Error>) -> Void) {
        let url = "\(baseURL)/doctor/\(doctorId)"
        AF.request(url, headers: headers)
            .validate()
            .responseDecodable(of: [Prescription].self) { response in
                switch response.result {
                case .success(let data): completion(.success(data))
                case .failure(let error): completion(.failure(error))
                }
            }
    }

    func createPrescription(patientId: Int, medications: String, description: String, completion: @escaping (Result<Void, Error>) -> Void) {
        let url = baseURL
        let parameters: [String: Any] = [
            "patient": ["id": patientId],
            "medications": medications,
            "description": description
        ]
        AF.request(url, method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: headers)
            .validate()
            .response { response in
                switch response.result {
                case .success: completion(.success(()))
                case .failure(let error): completion(.failure(error))
                }
            }
    }
}
