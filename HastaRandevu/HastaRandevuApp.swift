//
//  HastaRandevuApp.swift
//  HastaRandevu
//
//  Created by emircan güleç on 23.04.2025.
//

import SwiftUI

@main
struct HastaRandevuApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
