//
//  GameViewModels.swift
//  TicTacToe
//
//  Created by Максим on 17.07.2025.
//

import Combine
import Foundation

enum PlayerType: String {
    case human = "X"
    case computer = "O"
    
    var next: PlayerType {
        self == .computer ? .human : .computer
    }
}

class GameViewModel: ObservableObject {
    
    let winPatterns: [[Int]] = [
        [0, 1, 2], [3, 4, 5], [6, 7, 8], // rows
        [0, 3, 6], [1, 4, 7], [2, 5, 8], // columns
        [0, 4, 8], [2, 4, 6]             // diagonals
    ]
    
    @Published var board: [String?] = Array(repeating: nil, count: 9)
    @Published var currentPlayer: PlayerType = .human
    @Published var gameOver = false
    @Published var result: GameOutcome?
    @Published var isComputerThinking = false
    
    private var playerName: String
    
    init(playerName: String) {
        self.playerName = playerName
    }
    
    func makeMove(at index: Int) {
        guard board[index] == nil, !gameOver, currentPlayer == .human else { return }
        
        // Player's move
        board[index] = currentPlayer.rawValue
        checkGameStatus()
        
        if !gameOver {
            // Computer's move
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                self.makeComputerMove()
            }
        }
    }
    
    private func makeComputerMove() {
        isComputerThinking = true
        
        currentPlayer = .computer
        
        if let computerMove = self.findBestMove() {
            self.board[computerMove] = currentPlayer.rawValue
            self.checkGameStatus()
        }
        
        isComputerThinking = false
    }
    
    private func checkGameStatus() {
        if checkWin() {
            gameOver = true
            let didWin = currentPlayer == .human
            result = didWin ? .win : .lose
            saveResult(didWin: didWin)
        } else if board.allSatisfy({ $0 != nil }) {
            gameOver = true
            result = .draw
            saveResult(didWin: false)
        } else {
            currentPlayer = currentPlayer.next
        }
    }
    
    private func checkWin() -> Bool {
        return winPatterns.contains { pattern in
            pattern.allSatisfy { board[$0] == currentPlayer.rawValue }
        }
    }
    
    // MARK: - AI Logic
    private func findBestMove() -> Int? {
        // 1. Check if the computer can win with the next move
        if let winningMove = findWinningMove(for: .computer) {
            return winningMove
        }
        
        // 2. Check if the player can win with the next move and block it
        if let blockingMove = findWinningMove(for: .human) {
            return blockingMove
        }
        
        // 3. Take the center if it's available
        if board[4] == nil {
            return 4
        }
        
        // 4. Occupy the corner cells
        let corners = [0, 2, 6, 8]
        let emptyCorners = corners.filter { board[$0] == nil }
        if !emptyCorners.isEmpty {
            return emptyCorners.randomElement()
        }
        
        // 5. Occupy any available cell
        let emptyIndices = board.indices.filter { board[$0] == nil }
        return emptyIndices.randomElement()
    }
    
    private func findWinningMove(for player: PlayerType) -> Int? {
        
        for pattern in winPatterns {
            let cells = pattern.map { board[$0] }
            let emptyIndex = pattern.enumerated().first { board[$0.1] == nil }?.1
            
            // If two cells are occupied by the player and one is empty - it's a winning move
            if cells.filter({ $0 == player.rawValue }).count == 2, let emptyIndex = emptyIndex {
                return emptyIndex
            }
        }
        
        return nil
    }
    
    func resetGame() {
        board = Array(repeating: nil, count: 9)
        currentPlayer = .human
        gameOver = false
        result = nil
    }
    
    private func saveResult(didWin: Bool) {
        // Find or create a player
        let players = CoreDataManager.shared.fetchPlayers()
        var player = players.first(where: { $0.name == playerName })
        
        if let player = player {
            CoreDataManager.shared.updatePlayerStats(player: player, didWin: didWin)
        } else {
            player = CoreDataManager.shared.createPlayer(name: playerName)
        }
        
        // Send results to the "server" (simulation)
        sendResultsToServer(player: player!, didWin: didWin)
    }
    
    private func sendResultsToServer(player: Player, didWin: Bool) {

        let result = GameResult(
            playerId: player.id?.uuidString,
            playerName: player.name,
            result: didWin ? .win : .lose,
            streak: 5,
            timestamp: Date()
        )
        
        Task {
            do {
                let response: ServerResponse = try await NetworkManager.shared.sendGameResult(result)
                print("Result saved: \(response.message ?? "")")
            } catch {
                print("Error saving result: \(error.localizedDescription)")
            }
        }
    }
}
