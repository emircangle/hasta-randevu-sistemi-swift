import SwiftUI

struct ExportButton: View {
    let title: String
    let action: (@escaping (Result<URL, Error>) -> Void) -> Void

    @State private var isDownloading = false
    @State private var resultMessage: String?

    var body: some View {
        VStack(spacing: 6) {
            Button {
                isDownloading = true
                resultMessage = nil
                action { result in
                    DispatchQueue.main.async {
                        isDownloading = false
                        switch result {
                        case .success(let fileUrl):
                            resultMessage = "📥 \(fileUrl.lastPathComponent) başarıyla indirildi."
                        case .failure:
                            resultMessage = "❌ İndirme başarısız."
                        }
                    }
                }
            } label: {
                HStack {
                    if isDownloading {
                        ProgressView()
                    }
                    Text(title)
                        .frame(maxWidth: .infinity)
                }
                .padding()
                .background(Color.blue.opacity(0.2))
                .cornerRadius(10)
            }

            if let resultMessage {
                Text(resultMessage)
                    .font(.caption)
                    .foregroundColor(.gray)
            }
        }
        .padding(.horizontal)
    }
}
