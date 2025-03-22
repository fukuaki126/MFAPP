//
//  MFAPPApp.swift
//  MFAPP
//
//  Created by 福田叡人 on 2025/03/21.
//

import SwiftUI

@main
struct MFAPPApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
