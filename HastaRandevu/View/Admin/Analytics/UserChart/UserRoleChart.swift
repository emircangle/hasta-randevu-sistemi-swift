//
//  UserRoleChart.swift
//  HastaRandevu
//
//  Created by emircan güleç on 18.05.2025.
//

import SwiftUI
import Charts

struct UserRoleChart: View {
    @State private var data: [UserRoleCount] = []

    var body: some View {
        VStack {
            Text("📊 Rol Dağılımı").font(.headline)

            if data.isEmpty {
                ProgressView("Yükleniyor...")
            } else {
                Chart(data, id: \.role) { item in
                    SectorMark(
                        angle: .value("Adet", item.count),
                        innerRadius: .ratio(0.5)
                    )
                    .foregroundStyle(by: .value("Rol", item.role))
                }
                .frame(height: 300)
            }
        }
        .onAppear {
            AnalyticsService.shared.getUserCountByRole { result in
                if case .success(let result) = result {
                    self.data = result
                }
            }
        }
    }
}
