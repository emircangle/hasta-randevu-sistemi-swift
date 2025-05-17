//
//  DoctorCountByClinicChart.swift
//  HastaRandevu
//
//  Created by emircan güleç on 18.05.2025.
//

import SwiftUI
import Charts

struct DoctorCountByClinicChart: View {
    @State private var data: [ClinicDoctorCount] = []

    var body: some View {
        VStack {
            Text("🏥 Kliniklere Göre Doktor Sayısı").font(.headline)

            if data.isEmpty {
                ProgressView("Yükleniyor...")
            } else {
                Chart(data, id: \.clinicName) { item in
                    BarMark(
                        x: .value("Klinik", item.clinicName),
                        y: .value("Doktor Sayısı", item.count)
                    )
                }
                .frame(height: 300)
            }
        }
        .onAppear {
            AnalyticsService.shared.getDoctorCountByClinic { result in
                if case .success(let result) = result {
                    self.data = result
                }
            }
        }
    }
}
