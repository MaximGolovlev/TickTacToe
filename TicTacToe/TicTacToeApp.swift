//
//  TicTacToeApp.swift
//  TicTacToe
//
//  Created by Максим on 17.07.2025.
//

import SwiftUI

@main
struct TicTacToeApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
