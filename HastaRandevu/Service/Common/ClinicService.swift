import Foundation
import Alamofire

class ClinicService {
    static let shared = ClinicService()
    private init() {}

    let baseURL = "\(AppConfig.baseUrl)/hastarandevu/clinics" // ⬅️ private kaldırıldı

    var headers: HTTPHeaders? { // ⬅️ private kaldırıldı
        if let token = UserDefaults.standard.string(forKey: "jwtToken") {
            return ["Authorization": "Bearer \(token)"]
        }
        return nil
    }

    // ✅ 1. Klinikleri Listele
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

    // ✅ 2. Kliniklere Ait Doktorları Getir
    func getDoctorsByClinicId(clinicId: Int, completion: @escaping (Result<[User], Error>) -> Void) {
        let url = "\(baseURL)/\(clinicId)/doctors"
        AF.request(url, headers: headers)
            .validate()
            .responseDecodable(of: [User].self) { response in
                completion(response.result.mapError { $0 as Error })
            }
    }

    // ✅ 3. Klinik Ekle
    func createClinic(name: String, description: String, completion: @escaping (Result<Void, Error>) -> Void) {
        let parameters = ["name": name, "description": description]
        AF.request(baseURL,
                   method: .post,
                   parameters: parameters,
                   encoding: JSONEncoding.default,
                   headers: headers)
        .validate()
        .response { response in
            if let error = response.error {
                completion(.failure(error))
            } else {
                completion(.success(()))
            }
        }
    }

    // ✅ 4. Klinik Güncelle
    func updateClinic(id: Int, name: String, description: String, completion: @escaping (Result<Void, Error>) -> Void) {
        let parameters = ["name": name, "description": description]
        AF.request("\(baseURL)/\(id)",
                   method: .put,
                   parameters: parameters,
                   encoding: JSONEncoding.default,
                   headers: headers)
        .validate()
        .response { response in
            if let error = response.error {
                completion(.failure(error))
            } else {
                completion(.success(()))
            }
        }
    }

    // ✅ 5. Klinik Pasifleştir
    func deactivateClinic(id: Int, completion: @escaping (Result<Void, Error>) -> Void) {
        AF.request("\(baseURL)/\(id)/passive", method: .put, headers: headers)
            .validate()
            .response { response in
                if let error = response.error {
                    completion(.failure(error))
                } else {
                    completion(.success(()))
                }
            }
    }

    // ✅ 6. Klinik Aktifleştir
    func activateClinic(id: Int, completion: @escaping (Result<Void, Error>) -> Void) {
        AF.request("\(baseURL)/\(id)/activate", method: .put, headers: headers)
            .validate()
            .response { response in
                if let error = response.error {
                    completion(.failure(error))
                } else {
                    completion(.success(()))
                }
            }
    }
}
