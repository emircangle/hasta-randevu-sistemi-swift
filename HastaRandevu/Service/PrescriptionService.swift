import Foundation
import Alamofire

class PrescriptionService {
    static let shared = PrescriptionService()
    private init() {}

    private let baseURL = "http://localhost:8080/hastarandevu/prescriptions"

    private var headers: HTTPHeaders? {
        if let token = UserDefaults.standard.string(forKey: "jwtToken") {
            return ["Authorization": "Bearer \(token)"]
        }
        return nil
    }

    // 1. Hasta ID ile reçeteleri getir
    func getPrescriptionsByPatient(patientId: Int, completion: @escaping (Result<[Prescription], Error>) -> Void) {
        let url = "\(baseURL)/patient/\(patientId)"
        AF.request(url, headers: headers)
            .validate()
            .responseDecodable(of: [Prescription].self) { response in
                switch response.result {
                case .success(let prescriptions):
                    completion(.success(prescriptions))
                case .failure(let error):
                    completion(.failure(error))
                }
            }
    }

    // 2. Belirli döneme göre reçeteler (day, week, month, year)
    func getPrescriptionsByPeriod(patientId: Int, period: String, completion: @escaping (Result<[Prescription], Error>) -> Void) {
        let url = "\(baseURL)/patient/\(patientId)/filter?period=\(period)"
        AF.request(url, headers: headers)
            .validate()
            .responseDecodable(of: [Prescription].self) { response in
                switch response.result {
                case .success(let prescriptions):
                    completion(.success(prescriptions))
                case .failure(let error):
                    completion(.failure(error))
                }
            }
    }

    // 3. Açıklamada anahtar kelime ile arama
    func searchPrescriptions(keyword: String, completion: @escaping (Result<[Prescription], Error>) -> Void) {
        let url = "\(baseURL)/search?keyword=\(keyword)"
        AF.request(url, headers: headers)
            .validate()
            .responseDecodable(of: [Prescription].self) { response in
                switch response.result {
                case .success(let results):
                    completion(.success(results))
                case .failure(let error):
                    completion(.failure(error))
                }
            }
    }

    // 4. Tek bir reçeteyi ID ile getir
    func getPrescriptionById(id: Int, completion: @escaping (Result<Prescription, Error>) -> Void) {
        let url = "\(baseURL)/\(id)"
        AF.request(url, headers: headers)
            .validate()
            .responseDecodable(of: Prescription.self) { response in
                switch response.result {
                case .success(let prescription):
                    completion(.success(prescription))
                case .failure(let error):
                    completion(.failure(error))
                }
            }
    }

    // 5. Reçete oluştur
    func createPrescription(request: PrescriptionRequest, completion: @escaping (Result<Prescription, Error>) -> Void) {
        AF.request(baseURL, method: .post, parameters: request, encoder: JSONParameterEncoder.default, headers: headers)
            .validate()
            .responseDecodable(of: Prescription.self) { response in
                switch response.result {
                case .success(let prescription):
                    completion(.success(prescription))
                case .failure(let error):
                    completion(.failure(error))
                }
            }
    }

    // 6. Reçete güncelle
    func updatePrescription(id: Int, updatedRequest: PrescriptionRequest, completion: @escaping (Result<Prescription, Error>) -> Void) {
        let url = "\(baseURL)/\(id)"
        AF.request(url, method: .put, parameters: updatedRequest, encoder: JSONParameterEncoder.default, headers: headers)
            .validate()
            .responseDecodable(of: Prescription.self) { response in
                switch response.result {
                case .success(let updated):
                    completion(.success(updated))
                case .failure(let error):
                    completion(.failure(error))
                }
            }
    }

    // 7. Reçete sil
    func deletePrescription(id: Int, completion: @escaping (Result<Void, Error>) -> Void) {
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

    // 8. Doktora göre reçeteleri getir
    func getPrescriptionsByDoctor(doctorId: Int, completion: @escaping (Result<[Prescription], Error>) -> Void) {
        let url = "\(baseURL)/doctor/\(doctorId)"
        AF.request(url, headers: headers)
            .validate()
            .responseDecodable(of: [Prescription].self) { response in
                switch response.result {
                case .success(let prescriptions):
                    completion(.success(prescriptions))
                case .failure(let error):
                    completion(.failure(error))
                }
            }
    }

    // 9. Doktora göre filtreli reçete getir (period: day/week/month/year)
    func getPrescriptionsByDoctorAndPeriod(doctorId: Int, period: String, completion: @escaping (Result<[Prescription], Error>) -> Void) {
        let url = "\(baseURL)/doctor/\(doctorId)/filter?period=\(period)"
        AF.request(url, headers: headers)
            .validate()
            .responseDecodable(of: [Prescription].self) { response in
                switch response.result {
                case .success(let prescriptions):
                    completion(.success(prescriptions))
                case .failure(let error):
                    completion(.failure(error))
                }
            }
    }
}
