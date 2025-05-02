import Foundation

class LoginViewModel: ObservableObject {
    @Published var email = ""
    @Published var password = ""
    @Published var errorMessage: String?

    func login(completion: @escaping (Bool) -> Void) {
        AuthService.shared.login(email: email, password: password) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let token):
                    UserDefaults.standard.set(token, forKey: "jwtToken")
                    self.errorMessage = nil
                    completion(true)
                case .failure(let error):
                    self.errorMessage = "Giriş başarısız: \(error.localizedDescription)"
                    completion(false)
                }
            }
        }
    }
}
