//
//  UserGenderChart.swift
//  HastaRandevu
//
//  Created by emircan güleç on 18.05.2025.
//

import SwiftUI
import Charts

struct UserGenderChart: View {
    @State private var data: [GenderCount] = []

    var body: some View {
        VStack {
            Text("🚻 Cinsiyet Dağılımı").font(.headline)

            if data.isEmpty {
                ProgressView("Yükleniyor...")
            } else {
                Chart(data, id: \.gender) { item in
                    SectorMark(angle: .value("Adet", item.count))
                        .foregroundStyle(by: .value("Cinsiyet", item.gender))
                }
                .frame(height: 300)
            }
        }
        .onAppear {
            AnalyticsService.shared.getUserCountByGender { result in
                if case .success(let result) = result {
                    self.data = result
                }
            }
        }
    }
}
