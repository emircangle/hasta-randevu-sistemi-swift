//
//  Clinic.swift
//  HastaRandevu
//
//  Created by emircan güleç on 15.05.2025.
//

import Foundation

struct Clinic: Codable, Identifiable, Hashable, Equatable{
    let id: Int
    let name: String
    let description: String
    let isActive: Bool
}

