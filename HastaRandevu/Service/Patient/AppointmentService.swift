import Foundation
import Alamofire

class AppointmentService {
    static let shared = AppointmentService()
    private init() {}

    private let baseURL = "\(AppConfig.baseUrl)/hastarandevu/appointments"

    private var headers: HTTPHeaders? {
        if let token = UserDefaults.standard.string(forKey: "jwtToken") {
            return ["Authorization": "Bearer \(token)"]
        }
        return nil
    }

    // ✅ Tüm randevuları getir (Admin)
    func getAllAppointments(completion: @escaping (Result<[Appointments], Error>) -> Void) {
        AF.request(baseURL, headers: headers)
            .validate()
            .responseDecodable(of: [Appointments].self) { response in
                completion(response.result.mapError { $0 as Error })
            }
    }

    // ✅ Tarih periyoduna göre filtrele (day, week, month, year)
    func getAppointmentsByPeriod(_ period: String, completion: @escaping (Result<[Appointments], Error>) -> Void) {
        let url = "\(baseURL)/filter?period=\(period)"
        AF.request(url, headers: headers)
            .validate()
            .responseDecodable(of: [Appointments].self) { response in
                completion(response.result.mapError { $0 as Error })
            }
    }

    // ✅ Anahtar kelimeyle ara
    func searchAppointmentsByKeyword(_ keyword: String, completion: @escaping (Result<[Appointments], Error>) -> Void) {
        let url = "\(baseURL)/search?keyword=\(keyword)"
        AF.request(url, headers: headers)
            .validate()
            .responseDecodable(of: [Appointments].self) { response in
                completion(response.result.mapError { $0 as Error })
            }
    }

    // ✅ Randevu durumu güncelle
    func updateAppointmentStatus(id: Int, status: String, completion: @escaping (Result<Void, Error>) -> Void) {
        let url = "\(baseURL)/\(id)/status?status=\(status)"
        AF.request(url, method: .put, headers: headers)
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

    // ✅ Randevu sil
    func deleteAppointment(_ id: Int, completion: @escaping (Result<Void, Error>) -> Void) {
        let url = "\(baseURL)/\(id)"
        AF.request(url, method: .delete, headers: headers)
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

    // Diğer mevcut fonksiyonlar (korundu)
    func createAppointment(_ appointment: AppointmentRequest, completion: @escaping (Result<Appointments, Error>) -> Void) {
        AF.request(baseURL, method: .post, parameters: appointment, encoder: JSONParameterEncoder.default, headers: headers)
            .validate()
            .responseDecodable(of: Appointments.self) { response in
                switch response.result {
                case .success(let createdAppointment):
                    completion(.success(createdAppointment))
                case .failure(let error):
                    completion(.failure(error))
                }
            }
    }

    func getAppointmentsByPatientId(_ patientId: Int, completion: @escaping (Result<[Appointments], Error>) -> Void) {
        let url = "\(baseURL)/patient/\(patientId)"
        AF.request(url, headers: headers)
            .validate()
            .responseDecodable(of: [Appointments].self) { response in
                completion(response.result.mapError { $0 as Error })
            }
    }

    func getAppointmentsByDoctorAndDate(doctorId: Int, date: String, completion: @escaping (Result<[Appointments], Error>) -> Void) {
        let url = "\(baseURL)/doctor/\(doctorId)/date?date=\(date)"
        AF.request(url, headers: headers)
            .validate()
            .responseDecodable(of: [Appointments].self) { response in
                completion(response.result.mapError { $0 as Error })
            }
    }

    func cancelAppointment(_ id: Int, completion: @escaping (Result<Void, Error>) -> Void) {
        let url = "\(baseURL)/\(id)/cancel"
        AF.request(url, method: .put, headers: headers)
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

    func getAppointmentsByDoctorId(_ doctorId: Int, completion: @escaping (Result<[Appointments], Error>) -> Void) {
        let url = "\(baseURL)/doctor/\(doctorId)"
        AF.request(url, headers: headers)
            .validate()
            .responseDecodable(of: [Appointments].self) { response in
                completion(response.result.mapError { $0 as Error })
            }
    }
}
