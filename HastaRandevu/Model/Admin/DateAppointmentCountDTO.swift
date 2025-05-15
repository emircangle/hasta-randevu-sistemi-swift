//
//  DateAppointmentCountDTO.swift
//  HastaRandevu
//
//  Created by emircan güleç on 15.05.2025.
//

import Foundation

struct DateAppointmentCount: Codable, Identifiable {
    var id: String { date }  // veya UUID() da olabilir ama tarih daha mantıklı
    let date: String
    let appointmentCount: Int
}


