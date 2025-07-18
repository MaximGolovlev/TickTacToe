//
//  CoreDataManager.swift
//  TicTacToe
//
//  Created by Максим on 17.07.2025.
//

import CoreData

class CoreDataManager {
    static let shared = CoreDataManager()
    let persistentContainer: NSPersistentContainer
    
    private init() {
        persistentContainer = NSPersistentContainer(name: "TicTacToe")
        persistentContainer.loadPersistentStores { description, error in
            if let error = error {
                fatalError("Core Data Store failed \(error.localizedDescription)")
            }
        }
    }
    
    // MARK: - Player Management
    
    func createPlayer(name: String) -> Player {
        let player = Player(context: persistentContainer.viewContext)
        player.id = UUID()
        player.name = name
        player.wins = 0
        player.losses = 0
        player.streak = 0
        player.createdAt = Date()
        player.lastWinDate = nil
        saveContext()
        return player
    }
    
    func updatePlayerStats(player: Player, didWin: Bool) {
        if didWin {
            player.wins += 1
            // Check if the previous win was today to increase the streak
            if let lastWin = player.lastWinDate, Calendar.current.isDateInToday(lastWin) {
                player.streak += 1
            } else {
                player.streak = 1
            }
            player.lastWinDate = Date()
        } else {
            player.losses += 1
            player.streak = 0
        }
        saveContext()
    }
    
    func fetchPlayers() -> [Player] {
        let request: NSFetchRequest<Player> = Player.fetchRequest()
        request.sortDescriptors = [
            NSSortDescriptor(keyPath: \Player.wins, ascending: false),
            NSSortDescriptor(keyPath: \Player.streak, ascending: false)
        ]
        
        do {
            return try persistentContainer.viewContext.fetch(request)
        } catch {
            print("Error fetching players: \(error)")
            return []
        }
    }
    
    func saveContext() {
        do {
            try persistentContainer.viewContext.save()
        } catch {
            print("Error saving context: \(error)")
        }
    }
}
