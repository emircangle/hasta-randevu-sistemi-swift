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

    // MARK: - Genel GET Wrapper
    private func fetch<T: Decodable>(endpoint: String, completion: @escaping (Result<T, Error>) -> Void) {
        let url = "\(baseURL)\(endpoint)"

        AF.request(url, method: .get, headers: headers)
            .validate()
            .responseDecodable(of: T.self) { response in
                switch response.result {
                case .success(let decoded):
                    completion(.success(decoded))
                case .failure(let error):
                    print("❌ JSON decode hatası: \(error)")
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

    func fetchUsersByName(name: String, completion: @escaping (Result<[User], Error>) -> Void) {
        fetch(endpoint: "/name/\(name)", completion: completion)
    }

    func fetchUserByPhone(phone: String, completion: @escaping (Result<User, Error>) -> Void) {
        fetch(endpoint: "/phone/\(phone)", completion: completion)
    }

    func fetchDoctors(completion: @escaping (Result<[User], Error>) -> Void) {
        fetch(endpoint: "/role/DOKTOR", completion: completion)
    }

    func getCurrentUser(completion: @escaping (Result<User, Error>) -> Void) {
        guard let email = TokenUtil.getEmailFromToken() else {
            completion(.failure(NSError(domain: "", code: 401, userInfo: [NSLocalizedDescriptionKey: "Token'dan e-posta çözülemedi."])))
            return
        }
        fetchUserByEmail(email: email, completion: completion)
    }

    // MARK: - Kullanıcı CRUD

    func deleteUser(id: Int, completion: @escaping (Result<Void, Error>) -> Void) {
        let url = "\(baseURL)/\(id)"
        AF.request(url, method: .delete, headers: headers)
            .validate()
            .response { response in
                if let error = response.error {
                    completion(.failure(error))
                } else {
                    completion(.success(()))
                }
            }
    }

    func updateUser(_ user: User, completion: @escaping (Result<User, Error>) -> Void) {
        let url = "\(baseURL)/\(user.id)"
        AF.request(url, method: .put, parameters: user, encoder: JSONParameterEncoder.default, headers: headers)
            .validate()
            .responseDecodable(of: User.self) { response in
                completion(response.result.mapError { $0 as Error })
            }
    }

    func createUser(_ request: RegisterRequest, completion: @escaping (Result<User, Error>) -> Void) {
        let url = "\(AppConfig.baseUrl)/hastarandevu/auth/register"
        AF.request(url, method: .post, parameters: request, encoder: JSONParameterEncoder.default, headers: headers)
            .validate()
            .responseDecodable(of: User.self) { response in
                completion(response.result.mapError { $0 as Error })
            }
    }
    func getAllUsers(completion: @escaping (Result<[User], Error>) -> Void) {
        fetch(endpoint: "", completion: completion)
    }

}
