//
//  UserBloodTypeChart.swift
//  HastaRandevu
//
//  Created by emircan güleç on 18.05.2025.
//

import SwiftUI
import Charts

struct UserBloodTypeChart: View {
    @State private var data: [BloodTypeCount] = []

    var body: some View {
        VStack {
            Text("🩸 Kan Grubu Dağılımı").font(.headline)

            if data.isEmpty {
                ProgressView("Yükleniyor...")
            } else {
                Chart(data, id: \.bloodType) { item in
                    BarMark(
                        x: .value("Kan Grubu", item.bloodType),
                        y: .value("Kullanıcı Sayısı", item.count)
                    )
                }
                .frame(height: 300)
            }
        }
        .onAppear {
            AnalyticsService.shared.getUserCountByBloodType { result in
                if case .success(let result) = result {
                    self.data = result
                }
            }
        }
    }
}
