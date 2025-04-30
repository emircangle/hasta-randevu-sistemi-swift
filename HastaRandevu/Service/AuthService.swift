//
//  AuthService.swift
//  HastaRandevu
//
//  Created by emircan güleç on 23.04.2025.
//

import Foundation
import Alamofire

class AuthService {
    static let shared = AuthService()
    private init() {}
    
    private let baseURL = "http://192.168.1.103:8080/hastarandevu"

    func login(email: String, password: String, completion: @escaping (Result<String, Error>) -> Void) {
        let url = "\(baseURL)/auth/login"
        let parameters = LoginRequest(email: email, password: password)

        AF.request(url,
                   method: .post,
                   parameters: parameters,
                   encoder: JSONParameterEncoder.default)
        .validate()
        .responseDecodable(of: LoginResponse.self) { response in
            switch response.result {
            case .success(let loginResponse):
                completion(.success(loginResponse.token))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
   
    func registerUser(request: RegisterRequest, completion: @escaping (Result<String, Error>) -> Void) {
        let url = "\(baseURL)/auth/register"

        AF.request(url,
                   method: .post,
                   parameters: request,
                   encoder: JSONParameterEncoder.default)
        .validate()
        .response { response in
            if let statusCode = response.response?.statusCode, statusCode == 200 {
                completion(.success("Kayıt başarılı"))
            } else {
                let error = response.error ?? NSError(domain: "", code: response.response?.statusCode ?? -1, userInfo: [NSLocalizedDescriptionKey: "Bilinmeyen bir hata oluştu"]) as! AFError
                completion(.failure(error))
            }
        }
    }
}

