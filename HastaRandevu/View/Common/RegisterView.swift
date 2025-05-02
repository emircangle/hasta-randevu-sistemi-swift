import SwiftUI

struct RegisterView: View {
    @StateObject private var viewModel = RegisterViewModel()

    @State private var name = ""
    @State private var surname = ""
    @State private var email = ""
    @State private var password = ""
    @State private var phone = ""
    @State private var gender = "BELIRTILMEMIS"
    @State private var birthDate = Date()
    @State private var bloodGroup = ""
    @State private var chronicDiseases = ""

    @State private var showSuccessAlert = false
    @State private var navigateToLogin = false

    let genderOptions = ["BELIRTILMEMIS", "KADIN", "ERKEK"]
    let bloodGroups = ["ARH_POS", "ARH_NEG", "BRH_POS", "BRH_NEG", "ABRH_POS", "ABRH_NEG", "ORH_POS", "ORH_NEG"]

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    Text("Kayıt Ol")
                        .font(.largeTitle)
                        .bold()
                        .frame(maxWidth: .infinity, alignment: .center)
                        .padding(.top)

                    Group {
                        Text("Ad")
                        TextField("Ad", text: $name)

                        Text("Soyad")
                        TextField("Soyad", text: $surname)

                        Text("E-posta")
                        TextField("E-posta", text: $email)
                            .keyboardType(.emailAddress)
                            .autocapitalization(.none)

                        Text("Şifre")
                        SecureField("Şifre", text: $password)

                        Text("Telefon")
                        TextField("Telefon", text: $phone)
                            .keyboardType(.phonePad)
                    }
                    .textFieldStyle(RoundedBorderTextFieldStyle())

                    Text("Cinsiyet")
                    Picker("Cinsiyet", selection: $gender) {
                        ForEach(genderOptions, id: \.self) {
                            Text($0)
                        }
                    }
                    .pickerStyle(.segmented)

                    Text("Doğum Tarihi")
                    DatePicker("", selection: $birthDate, displayedComponents: .date)
                        .datePickerStyle(.compact)

                    Text("Kan Grubu (isteğe bağlı)")
                    Picker("Kan Grubu", selection: $bloodGroup) {
                        ForEach(bloodGroups, id: \.self) {
                            Text($0)
                        }
                    }
                    .pickerStyle(.menu)

                    Text("Kronik Rahatsızlıklar (isteğe bağlı)")
                    TextField("Kronik Rahatsızlıklar", text: $chronicDiseases)
                        .textFieldStyle(RoundedBorderTextFieldStyle())

                    if let errorMessage = viewModel.errorMessage {
                        Text(errorMessage)
                            .foregroundColor(.red)
                    }

                    Button("Kayıt Ol") {
                        viewModel.registerUser(
                            name: name,
                            surname: surname,
                            email: email,
                            password: password,
                            phone: phone,
                            gender: gender,
                            birthDate: birthDate,
                            bloodGroup: bloodGroup,
                            chronicDiseases: chronicDiseases
                        )
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.green)
                    .foregroundColor(.white)
                    .cornerRadius(10)

                    // Yönlendirme Linki (Gizli)
                    NavigationLink(destination: LoginView(), isActive: $navigateToLogin) {
                        EmptyView()
                    }
                }
                .padding()
            }
            .alert("Kayıt Başarılı", isPresented: $showSuccessAlert) {
                Button("Tamam") {
                    navigateToLogin = true
                }
            } message: {
                Text("Şimdi giriş yapabilirsiniz.")
            }
            .onChange(of: viewModel.isRegistered) { registered in
                if registered {
                    showSuccessAlert = true
                }
            }
        }
    }
}
// seee 

