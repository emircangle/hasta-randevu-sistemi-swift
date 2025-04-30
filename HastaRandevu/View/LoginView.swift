//
//  LoginView.swift
//  HastaRandevu
//
//  Created by emircan güleç on 23.04.2025.
//

import Foundation
import SwiftUI

struct LoginView: View {
    @StateObject private var viewModel = LoginViewModel()

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
                viewModel.login()
            }
            .padding()
            .background(Color.blue)
            .foregroundColor(.white)
            .cornerRadius(8)

        }
        .padding()
        .fullScreenCover(isPresented: $viewModel.isLoggedIn) {
            // Giriş başarılıysa ana ekran
            MainView()
        }
    }
}

