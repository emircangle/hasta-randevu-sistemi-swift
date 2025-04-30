//
//  LoginViewModel.swift
//  HastaRandevu
//
//  Created by emircan güleç on 23.04.2025.
//

import Foundation

class LoginViewModel: ObservableObject {
    @Published var email = ""
    @Published var password = ""
    @Published var isLoggedIn = false
    @Published var errorMessage: String?

    func login() {
        AuthService.shared.login(email: email, password: password) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let token):
                    // Token'ı UserDefaults'a kaydet
                    UserDefaults.standard.set(token, forKey: "jwtToken")
                    self.isLoggedIn = true
                case .failure(let error):
                    self.errorMessage = error.localizedDescription
                    self.isLoggedIn = false
                }
            }
        }
    }
}
