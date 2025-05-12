import SwiftUI

struct AdminUserListView: View {
    @State private var selectedRole: String = "HASTA"
    @State private var users: [User] = []
    @State private var filteredUsers: [User] = []
    @State private var allUsers: [User] = []

    @State private var nameFilter = ""
    @State private var emailFilter = ""
    @State private var genderFilter = ""
    @State private var bloodTypeFilter = ""
    @State private var specializationFilter = ""

    @State private var navigateToNewDoctor = false
    @State private var navigateToNewPatient = false
    @State private var navigateToNewAdmin = false

    @State private var selectedUserForDetail: User?
    @State private var selectedUserForEdit: User?
    @State private var showDeleteConfirmation = false
    @State private var userToDeleteId: Int?

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 12) {
                    Text("👥 Kullanıcı Yönetimi")
                        .font(.title2)
                        .bold()
                        .padding(.top)

                    roleSelectionSection
                    filterSection
                    userListSection
                    Divider()
                    addUserButtonsSection
                    navigationLinksSection
                }
                .padding()
            }
            .onAppear(perform: fetchAllUsers)
            .onChange(of: nameFilter) { _ in applyFilter() }
            .onChange(of: emailFilter) { _ in applyFilter() }
            .onChange(of: genderFilter) { _ in applyFilter() }
            .onChange(of: bloodTypeFilter) { _ in applyFilter() }
            .onChange(of: specializationFilter) { _ in applyFilter() }
            .navigationTitle("Admin Paneli")
            .alert("Kullanıcıyı silmek istiyor musunuz?", isPresented: $showDeleteConfirmation, presenting: userToDeleteId) { id in
                Button("Sil", role: .destructive) {
                    deleteUser(id)
                }
                Button("İptal", role: .cancel) {}
            }
        }
    }

    private var roleSelectionSection: some View {
        HStack {
            ForEach(["HASTA", "DOKTOR", "ADMIN"], id: \.self) { role in
                Button(action: {
                    selectedRole = role
                    resetFilters()
                    applyFilter()
                }) {
                    Text(role)
                        .padding(.horizontal)
                        .padding(.vertical, 6)
                        .background(selectedRole == role ? Color.blue : Color.gray.opacity(0.3))
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
            }
        }
    }

    private var filterSection: some View {
        VStack(spacing: 8) {
            TextField("İsme göre ara", text: $nameFilter)
            TextField("E-posta ile ara", text: $emailFilter)

            Picker("Cinsiyet", selection: $genderFilter) {
                Text("Tümü").tag("")
                Text("ERKEK").tag("ERKEK")
                Text("KADIN").tag("KADIN")
                Text("BELIRTILMEMIS").tag("BELIRTILMEMIS")
            }
            .pickerStyle(SegmentedPickerStyle())

            if selectedRole == "HASTA" {
                Picker("Kan Grubu", selection: $bloodTypeFilter) {
                    Text("Tümü").tag("")
                    ForEach(["ARH_POS", "ARH_NEG", "BRH_POS", "BRH_NEG", "ABRH_POS", "ABRH_NEG", "ORH_POS", "ORH_NEG"], id: \.self) {
                        Text($0).tag($0)
                    }
                }
            }

            if selectedRole == "DOKTOR" {
                TextField("Uzmanlık", text: $specializationFilter)
            }
        }
        .textFieldStyle(RoundedBorderTextFieldStyle())
        .padding(.horizontal)
    }

    private var userListSection: some View {
        VStack(spacing: 8) {
            ForEach(filteredUsers, id: \.id) { user in
                VStack(alignment: .leading, spacing: 4) {
                    Text("👤 \(user.name) \(user.surname)").font(.headline)
                    Text("✉️ \(user.email)")
                    Text("📞 \(user.phoneNumber)")
                    Text("🎯 Rol: \(user.role)")
                    if user.role == "DOKTOR" {
                        Text("🏥 Uzmanlık: \(user.specialization ?? "-")")
                    }

                    HStack {
                        Button("✏️ Güncelle") {
                            print("➡️ Güncelle butonuna tıklandı: \(user.id)")
                            selectedUserForEdit = nil
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.01) {
                                selectedUserForEdit = user
                                print("✅ selectedUserForEdit set edildi: \(user.email)")
                            }
                        }
                        Button("🗑️ Sil", role: .destructive) {
                            userToDeleteId = user.id
                            showDeleteConfirmation = true
                        }
                        Button("🔍 Detay") {
                            print("➡️ Detay butonuna tıklandı: \(user.id)")
                            selectedUserForDetail = nil
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.01) {
                                selectedUserForDetail = user
                                print("✅ selectedUserForDetail set edildi: \(user.email)")
                            }
                        }
                    }
                    .padding(.top, 4)
                }
                .padding()
                .background(Color.gray.opacity(0.1))
                .cornerRadius(10)
            }
        }
    }

    private var addUserButtonsSection: some View {
        VStack {
            if selectedRole == "HASTA" {
                Button("➕ Yeni Hasta Ekle") {
                    navigateToNewPatient = true
                }
            } else if selectedRole == "DOKTOR" {
                Button("➕ Yeni Doktor Ekle") {
                    navigateToNewDoctor = true
                }
            } else if selectedRole == "ADMIN" {
                Button("➕ Yeni Admin Ekle") {
                    navigateToNewAdmin = true
                }
            }
        }
        .padding(.top, 8)
    }

    private var navigationLinksSection: some View {
        VStack {
            NavigationLink(destination: patientDestinationView, isActive: $navigateToNewPatient) {
                EmptyView()
            }

            NavigationLink(destination: doctorDestinationView, isActive: $navigateToNewDoctor) {
                EmptyView()
            }

            NavigationLink(destination: adminDestinationView, isActive: $navigateToNewAdmin) {
                EmptyView()
            }

            NavigationLink(
                destination: selectedUserForDetail.map { UserDetailView(user: $0) },
                isActive: Binding(
                    get: { selectedUserForDetail != nil },
                    set: { if !$0 { selectedUserForDetail = nil } }
                )
            ) {
                EmptyView()
            }

            NavigationLink(
                destination: selectedUserForEdit.map {
                    UserEditView(user: $0, onSave: {
                        selectedUserForEdit = nil
                        fetchAllUsers()
                    })
                },
                isActive: Binding(
                    get: { selectedUserForEdit != nil },
                    set: { if !$0 { selectedUserForEdit = nil } }
                )
            ) {
                EmptyView()
            }
        }
    }




    private var patientDestinationView: some View {
        NewPatientView(onSuccess: {
            navigateToNewPatient = false
            fetchAllUsers()
        })
    }

    private var doctorDestinationView: some View {
        NewDoctorView(onSuccess: {
            navigateToNewDoctor = false
            fetchAllUsers()
        })
    }

    private var adminDestinationView: some View {
        NewAdminView(onSuccess: {
            navigateToNewAdmin = false
            fetchAllUsers()
        })
    }

    private func resetFilters() {
        nameFilter = ""
        emailFilter = ""
        genderFilter = ""
        bloodTypeFilter = ""
        specializationFilter = ""
    }

    private func fetchAllUsers() {
        let roles = ["HASTA", "DOKTOR", "ADMIN"]
        var combined: [User] = []
        let group = DispatchGroup()

        for role in roles {
            group.enter()
            UserService.shared.fetchUsersByRole(role: role) { result in
                if case .success(let list) = result {
                    combined.append(contentsOf: list)
                }
                group.leave()
            }
        }

        group.notify(queue: .main) {
            self.allUsers = combined
            self.applyFilter()
        }
    }

    private func applyFilter() {
        let trimmedName = nameFilter.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedEmail = emailFilter.trimmingCharacters(in: .whitespacesAndNewlines)

        filteredUsers = allUsers.filter { user in
            let matchesRole = user.role.lowercased() == selectedRole.lowercased()
            let matchesName = trimmedName.isEmpty || user.name.lowercased().contains(trimmedName.lowercased())
            let matchesEmail = trimmedEmail.isEmpty || user.email.lowercased().contains(trimmedEmail.lowercased())
            let matchesGender = genderFilter.isEmpty || user.gender == genderFilter
            let matchesBlood = bloodTypeFilter.isEmpty || (user.bloodType ?? "") == bloodTypeFilter
            let matchesSpec = specializationFilter.isEmpty || (user.specialization ?? "").lowercased().contains(specializationFilter.lowercased())
            return matchesRole && matchesName && matchesEmail && matchesGender && matchesBlood && matchesSpec
        }
    }

    private func deleteUser(_ id: Int) {
        UserService.shared.deleteUser(id: id) { result in
            switch result {
            case .success:
                allUsers.removeAll { $0.id == id }
                applyFilter()
            case .failure(let error):
                print("Silme hatası: \(error.localizedDescription)")
            }
        }
    }
}
