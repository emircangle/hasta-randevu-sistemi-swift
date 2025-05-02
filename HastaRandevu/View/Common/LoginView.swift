import Foundation
import SwiftUI

struct LoginView: View {
    @StateObject private var viewModel = LoginViewModel()
    @State private var userRole: String?
    @State private var isLoggedIn = false

    var body: some View {
        VStack(spacing: 16) {
            TextField("Email", text: $viewModel.email)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .autocapitalization(.none)

            SecureField("Password", text: $viewModel.password)
                .textFieldStyle(RoundedBorderTextFieldStyle())

            if let error = viewModel.errorMessage {
                Text(error)
                    .foregroundColor(.red)
            }

            Button("Giriş Yap") {
                viewModel.login { success in
                    if success {
                        self.userRole = TokenUtil.getRoleFromToken()
                        self.isLoggedIn = true
                    }
                }
            }
            .padding()
            .background(Color.blue)
            .foregroundColor(.white)
            .cornerRadius(8)
        }
        .padding()
        .fullScreenCover(isPresented: $isLoggedIn) {
            destinationView()
        }
    }

    @ViewBuilder
    private func destinationView() -> some View {
        if userRole == "DOKTOR" || userRole == "ROLE_DOKTOR" {
            DoctorMainView()
        } else {
            MainView() // HASTA
        }
    }
}
