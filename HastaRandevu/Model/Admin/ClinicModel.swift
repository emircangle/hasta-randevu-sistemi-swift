//
//  Clinic.swift
//  HastaRandevu
//
//  Created by emircan güleç on 21.05.2025.
//

import Foundation

struct ClinicModel: Codable, Identifiable {
    let id: Int
    let name: String
    let description: String
    let isActive: Bool
}

