import SwiftUI

struct AdminComplaintsView: View {
    @State private var complaints: [Complaint] = []
    @State private var filteredComplaints: [Complaint] = []

    @State private var statusFilter: String = ""
    @State private var searchKeyword: String = ""

    @State private var editingComplaintId: Int?
    @State private var updatedStatus: String = ""
    @State private var updatedNote: String = ""

    var body: some View {
        NavigationStack {
            VStack(spacing: 16) {
                Text("\u{1F4AC} Şikayet Yönetimi")
                    .font(.title2)
                    .bold()

                // Filtre Alanı
                HStack {
                    Picker("Durum", selection: $statusFilter) {
                        Text("Tümü").tag("")
                        Text("Beklemede").tag("BEKLEMEDE")
                        Text("İncelemede").tag("INCELEMEDE")
                        Text("Çözüldü").tag("COZULDU")
                    }
                    .onChange(of: statusFilter) { _ in filterComplaints() }

                    TextField("İsim ile ara", text: $searchKeyword)
                        .onChange(of: searchKeyword) { _ in filterComplaints() }
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                }
                .padding(.horizontal)

                // Şikayet Listesi
                List {
                    ForEach(filteredComplaints) { complaint in
                        VStack(alignment: .leading, spacing: 4) {
                            Text("\(complaint.user.name ?? "") \(complaint.user.surname ?? "")").bold()
                            Text("İçerik: \(complaint.content ?? "")")
                            if let clinicName = complaint.clinic?.name {
                                Text("Klinik: \(clinicName)")
                            } else {
                                Text("Klinik: Belirtilmemiş")
                            }


                            if editingComplaintId == complaint.id {
                                Picker("Durum", selection: $updatedStatus) {
                                    Text("BEKLEMEDE").tag("BEKLEMEDE")
                                    Text("INCELEMEDE").tag("INCELEMEDE")
                                    Text("COZULDU").tag("COZULDU")
                                }
                                .pickerStyle(.segmented)

                                TextField("Admin Notu", text: $updatedNote)
                                    .textFieldStyle(.roundedBorder)

                                HStack {
                                    Button("💾 Kaydet") {
                                        saveEdit(complaint.id)
                                    }
                                    .buttonStyle(.borderedProminent)

                                    Button("❌ İptal") {
                                        cancelEdit()
                                    }
                                    .buttonStyle(.bordered)
                                    .foregroundColor(.red)
                                }
                            } else {
                                Text("Durum: \(complaint.status ?? "-")")
                                Text("Admin Notu: \(complaint.adminNote ?? "-")")

                                HStack {
                                    Button("✏️ Güncelle") {
                                        startEditing(complaint)
                                    }
                                    .buttonStyle(.bordered)

                                    Button("🗑️ Sil", role: .destructive) {
                                        deleteComplaint(complaint.id)
                                    }
                                    .buttonStyle(.bordered)
                                }
                            }
                        }
                        .padding(8)
                    }
                }
            }
            .onAppear { getAllComplaints() }
            .navigationTitle("Şikayetler")
        }
    }

    private func getAllComplaints() {
        ComplaintService.shared.getAllComplaints { result in
            switch result {
            case .success(let list):
                self.complaints = list
                self.filteredComplaints = applyKeywordFilter(list)
            case .failure:
                print("Şikayetler getirilemedi.")
            }
        }
    }

    private func filterComplaints() {
        if statusFilter.isEmpty {
            getAllComplaints()
        } else {
            ComplaintService.shared.getComplaintsByStatus(status: statusFilter) { result in
                switch result {
                case .success(let list):
                    self.complaints = list
                    self.filteredComplaints = applyKeywordFilter(list)
                case .failure:
                    print("Duruma göre şikayetler getirilemedi.")
                }
            }
        }
    }

    private func applyKeywordFilter(_ data: [Complaint]) -> [Complaint] {
        guard !searchKeyword.isEmpty else { return data }
        return data.filter { complaint in
            let fullName = ((complaint.user.name ?? "") + " " + (complaint.user.surname ?? "")).lowercased()
            return fullName.contains(searchKeyword.lowercased())
        }
    }

    private func startEditing(_ complaint: Complaint) {
        editingComplaintId = complaint.id
        updatedStatus = complaint.status ?? "BEKLEMEDE"
        updatedNote = complaint.adminNote ?? ""
    }

    private func cancelEdit() {
        editingComplaintId = nil
        updatedStatus = ""
        updatedNote = ""
    }

    private func saveEdit(_ id: Int) {
        guard let fullComplaint = complaints.first(where: { $0.id == id }) else {
            print("🔴 Şikayet bulunamadı.")
            return
        }

        ComplaintService.shared.updateComplaint(id: id, fullComplaint: fullComplaint, newStatus: updatedStatus, newNote: updatedNote) { result in
            switch result {
            case .success:
                getAllComplaints()
                cancelEdit()
            case .failure(let error):
                print("❌ Güncelleme başarısız: \(error.localizedDescription)")
            }
        }
    }

    private func deleteComplaint(_ id: Int) {
        ComplaintService.shared.deleteComplaint(id: id) { result in
            switch result {
            case .success:
                getAllComplaints()
            case .failure(let error):
                print("❌ Silme başarısız: \(error.localizedDescription)")
            }
        }
    }
}
