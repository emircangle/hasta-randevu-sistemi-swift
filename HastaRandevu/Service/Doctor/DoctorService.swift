import Foundation
import Alamofire

class DoctorService {
    static let shared = DoctorService()
    private init() {}

    private let baseURL = "\(AppConfig.baseUrl)/hastarandevu"
    
    private var headers: HTTPHeaders? {
        if let token = UserDefaults.standard.string(forKey: "jwtToken") {
            return ["Authorization": "Bearer \(token)"]
        }
        return nil
    }

    func getAppointmentsByDoctor(doctorId: Int, completion: @escaping (Result<[DoctorAppointment], Error>) -> Void) {
        let url = "\(baseURL)/appointments/doctor/\(doctorId)"

        AF.request(url, headers: headers)
            .validate()
            .responseDecodable(of: [DoctorAppointment].self) { response in
                switch response.result {
                case .success(let data): completion(.success(data))
                case .failure(let error): completion(.failure(error))
                }
            }
    }
}
