//
//  TicTacToeApp.swift
//  TicTacToe
//
//  Created by Максим on 17.07.2025.
//

import SwiftUI

@main
struct TicTacToeApp: App {
    let persistenceController = CoreDataManager.shared

    var body: some Scene {
        WindowGroup {
            StartView()
                .environment(\.managedObjectContext, persistenceController.persistentContainer.viewContext)
        }
    }
}
