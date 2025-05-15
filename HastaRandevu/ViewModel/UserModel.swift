//
//  UserModel.swift
//  HastaRandevu
//
//  Created by emircan güleç on 26.04.2025.
//

import Foundation

struct User: Codable, Identifiable {
    var id: Int
    var name: String
    var surname: String
    var email: String
    var phoneNumber: String
    var gender: String
    var birthDate: String?
    var bloodType: String?
    var chronicDiseases: String?
    var specialization: String?
    var role: String
    var clinic: Clinic?
}
