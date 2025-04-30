//
//  UserModel.swift
//  HastaRandevu
//
//  Created by emircan güleç on 26.04.2025.
//

import Foundation

struct User: Codable {
    let id: Int
    let name: String
    let surname: String
    let email: String
    let phoneNumber: String
    let gender: String
    let birthDate: String?
    let bloodType: String?
    let chronicDiseases: String?
}

