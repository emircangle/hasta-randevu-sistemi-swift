import Foundation
import Alamofire

class DoctorPatientReportService {
    static let shared = DoctorPatientReportService()
    private init() {}

    private let baseURL = "\(AppConfig.baseUrl)/hastarandevu/patient-report"

    private var headers: HTTPHeaders? {
        if let token = UserDefaults.standard.string(forKey: "jwtToken") {
            return ["Authorization": "Bearer \(token)"]
        }
        return nil
    }

    func getReportsByPatientId(_ patientId: Int, completion: @escaping (Result<[PatientReport], Error>) -> Void) {
        let url = "\(baseURL)/patient/\(patientId)"
        AF.request(url, headers: headers)
            .validate()
            .responseDecodable(of: [PatientReport].self) { response in
                switch response.result {
                case .success(let data): completion(.success(data))
                case .failure(let error): completion(.failure(error))
                }
            }
    }

    func getReportsByPatientAndPeriod(_ patientId: Int, period: String, completion: @escaping (Result<[PatientReport], Error>) -> Void) {
        let url = "\(baseURL)/patient/\(patientId)/filter?period=\(period)"
        AF.request(url, headers: headers)
            .validate()
            .responseDecodable(of: [PatientReport].self) { response in
                switch response.result {
                case .success(let data): completion(.success(data))
                case .failure(let error): completion(.failure(error))
                }
            }
    }

    func searchByKeyword(_ keyword: String, completion: @escaping (Result<[PatientReport], Error>) -> Void) {
        let url = "\(baseURL)/search?keyword=\(keyword)"
        AF.request(url, headers: headers)
            .validate()
            .responseDecodable(of: [PatientReport].self) { response in
                switch response.result {
                case .success(let data): completion(.success(data))
                case .failure(let error): completion(.failure(error))
                }
            }
    }

    func createReport(_ request: PatientReportRequest, completion: @escaping (Result<Void, Error>) -> Void) {
        AF.request(baseURL, method: .post, parameters: request, encoder: JSONParameterEncoder.default, headers: headers)
            .validate()
            .response { response in
                switch response.result {
                case .success: completion(.success(()))
                case .failure(let error): completion(.failure(error))
                }
            }
    }

    func updateReport(id: Int, updatedData: PatientReportRequest, completion: @escaping (Result<Void, Error>) -> Void) {
        let url = "\(baseURL)/\(id)"
        AF.request(url, method: .put, parameters: updatedData, encoder: JSONParameterEncoder.default, headers: headers)
            .validate()
            .response { response in
                switch response.result {
                case .success: completion(.success(()))
                case .failure(let error): completion(.failure(error))
                }
            }
    }

    func deleteReport(id: Int, completion: @escaping (Result<Void, Error>) -> Void) {
        let url = "\(baseURL)/\(id)"
        AF.request(url, method: .delete, headers: headers)
            .validate()
            .response { response in
                switch response.result {
                case .success: completion(.success(()))
                case .failure(let error): completion(.failure(error))
                }
            }
    }
    func getReportsByDoctorId(doctorId: Int, completion: @escaping (Result<[PatientReport], Error>) -> Void) {
        let url = "\(baseURL)/doctor/\(doctorId)"
        AF.request(url, headers: headers)
            .validate()
            .responseDecodable(of: [PatientReport].self) { response in
                switch response.result {
                case .success(let data): completion(.success(data))
                case .failure(let error): completion(.failure(error))
                }
            }
    }


}
