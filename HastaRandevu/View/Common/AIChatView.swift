import SwiftUI

struct AIChatView: View {
    @State private var isOpen = false
    @State private var complaintText = ""
    @State private var isLoading = false
    @State private var response: String? = nil
    @State private var suggestedClinic: String? = nil
    @State private var readonly = false
    @State private var navigateToAppointment = false

    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            VStack {
                if isOpen {
                    VStack(alignment: .leading) {
                        HStack {
                            Text("🤖 Yapay Zeka")
                                .font(.headline)
                            Spacer()
                            Button("✖") { toggle() }
                        }

                        TextEditor(text: $complaintText)
                            .frame(height: 80)
                            .border(Color.gray)
                            .disabled(readonly)
                            .padding(.vertical, 4)

                        Button(isLoading ? "Yükleniyor..." : "Gönder") {
                            submitComplaint()
                        }
                        .disabled(isLoading || readonly)

                        if let response = response {
                            Divider()
                            Text("🩺 Poliklinik Önerisi: \(suggestedClinic ?? "-")").bold()
                            Text("💡 Tavsiye: \(extractAdvice(from: response))")

                            HStack {
                                Button("Randevu Al") {
                                    navigateToAppointment = true
                                }
                                Button("Yeni Şikayet") {
                                    reset()
                                }
                            }.padding(.top, 6)
                        }
                    }
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(12)
                    .shadow(radius: 5)
                    .frame(width: 280)
                    .padding()
                } else {
                    Button("🤖") { toggle() }
                        .font(.largeTitle)
                        .padding()
                }
            }

            NavigationLink(
                destination: AppointmentCreateView(selectedClinic: suggestedClinic ?? ""),
                isActive: $navigateToAppointment,
                label: { EmptyView() }
            )
            .onChange(of: navigateToAppointment) { newValue in
                if newValue == true {
                    // yönlendirme sonrası resetle
                    reset()
                    isOpen = false
                    navigateToAppointment = false
                }
            }
        }
    }

    private func toggle() { isOpen.toggle() }

    private func submitComplaint() {
        guard !complaintText.trimmingCharacters(in: .whitespaces).isEmpty else { return }

        isLoading = true
        response = nil
        suggestedClinic = nil
        readonly = true

        AIService.shared.analyzeComplaint(complaintText) { result in
            DispatchQueue.main.async {
                self.isLoading = false
                switch result {
                case .success(let result):
                    self.response = result
                    if let match = result.range(of: #"Poliklinik:\s*(.+)"#, options: .regularExpression),
                       let extracted = result[match].split(separator: ":").last {
                        self.suggestedClinic = String(extracted).trimmingCharacters(in: .whitespaces)
                    }
                case .failure:
                    self.response = "Yapay zeka şu anda yanıt veremiyor."
                }
            }
        }
    }

    private func reset() {
        complaintText = ""
        response = nil
        suggestedClinic = nil
        readonly = false
    }

    private func extractAdvice(from response: String) -> String {
        if let adviceRange = response.range(of: "Tavsiye:") {
            return String(response[adviceRange.upperBound...]).trimmingCharacters(in: .whitespacesAndNewlines)
        }
        return "-"
    }
}
