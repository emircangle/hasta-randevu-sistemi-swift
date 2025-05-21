import SwiftUI
import Charts

struct ComplaintSubjectChart: View {
    @State private var subjectCounts: [ComplaintSubjectCount] = []
    @State private var errorMessage: String?

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("📚 Şikayet Konularına Göre Dağılım")
                .font(.title2)
                .bold()

            if let errorMessage {
                Text("❌ \(errorMessage)").foregroundColor(.red)
            } else if subjectCounts.isEmpty {
                ProgressView("Yükleniyor...")
            } else {
                Chart(subjectCounts, id: \.subject) { item in
                    BarMark(
                        x: .value("Konu", item.subject),
                        y: .value("Şikayet Sayısı", item.count)
                    )
                }
                .frame(height: 300)
                .chartXAxis {
                    AxisMarks(values: .automatic) { value in
                        AxisValueLabel() {
                            if let text = value.as(String.self) {
                                Text(text).rotationEffect(.degrees(40))
                            }
                        }
                    }
                }
            }

            Spacer()
        }
        .padding()
        .onAppear(perform: loadComplaintSubjectData)
    }

    private func loadComplaintSubjectData() {
        AnalyticsService.shared.getComplaintCountBySubject { result in
            switch result {
            case .success(let data):
                self.subjectCounts = data
            case .failure(let error):
                self.errorMessage = error.localizedDescription
            }
        }
    }
}
