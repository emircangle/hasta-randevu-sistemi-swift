import Foundation
import Alamofire

class UserService {
    static let shared = UserService()
    private init() {}

    private let baseURL = "\(AppConfig.baseUrl)/hastarandevu/users"

    private var headers: HTTPHeaders? {
        if let token = UserDefaults.standard.string(forKey: "jwtToken") {
            return ["Authorization": "Bearer \(token)"]
        }
        return nil
    }

    // MARK: - Genel Fonksiyonlar

    private func fetch<T: Decodable>(endpoint: String, completion: @escaping (Result<T, Error>) -> Void) {
        let url = "\(baseURL)\(endpoint)"

        AF.request(url, method: .get, headers: headers)
            .validate()
            .responseDecodable(of: T.self) { response in
                switch response.result {
                case .success(let decoded):
                    completion(.success(decoded))
                case .failure(let error):
                    completion(.failure(error))
                }
            }
    }

    // MARK: - Kullanıcı Çekme Fonksiyonları

    func fetchUserByEmail(email: String, completion: @escaping (Result<User, Error>) -> Void) {
        fetch(endpoint: "/email/\(email)", completion: completion)
    }

    func fetchUserById(id: Int, completion: @escaping (Result<User, Error>) -> Void) {
        fetch(endpoint: "/\(id)", completion: completion)
    }

    func fetchUsersByRole(role: String, completion: @escaping (Result<[User], Error>) -> Void) {
        fetch(endpoint: "/role/\(role)", completion: completion)
    }

    func fetchUsersByGender(gender: String, completion: @escaping (Result<[User], Error>) -> Void) {
        fetch(endpoint: "/gender/\(gender)", completion: completion)
    }

    func fetchUsersBySpecialization(specialization: String, completion: @escaping (Result<[User], Error>) -> Void) {
        fetch(endpoint: "/specialization/\(specialization)", completion: completion)
    }

    func fetchUsersByBloodType(bloodType: String, completion: @escaping (Result<[User], Error>) -> Void) {
        fetch(endpoint: "/blood-type/\(bloodType)", completion: completion)
    }

    func fetchDoctors(completion: @escaping (Result<[User], Error>) -> Void) {
        fetch(endpoint: "/role/DOKTOR", completion: completion)
    }
}
