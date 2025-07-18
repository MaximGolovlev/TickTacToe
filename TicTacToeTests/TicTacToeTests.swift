//
//  TicTacToeTests.swift
//  TicTacToeTests
//
//  Created by Максим on 17.07.2025.
//

import Testing
@testable import TicTacToe
import Foundation

final class MockNetworkManager: NetworkServiceProtocol {

    var shouldSucceed = true
    var lastReceivedResult: GameResult?
    
    func sendGameResult(_ result: GameResult) async throws -> ServerResponse {
        lastReceivedResult = result
        
        if shouldSucceed {
            return ServerResponse(status: "success", message: "Result saved")
        } else {
            throw NetworkError.serverError(statusCode: 500, message: "Test error")
        }
    }
}

struct GameResultTests {

    @Test func testSendGameResultSuccess() async throws {
        // Given
        let mockManager = MockNetworkManager()
        let player = Player(context: CoreDataManager.shared.persistentContainer.viewContext)
        player.id = UUID()
        player.name = "Test Player"
        
        // When
        let result = GameResult(
            playerId: player.id?.uuidString,
            playerName: player.name,
            result: .win,
            streak: 5,
            timestamp: Date()
        )
        
        let response: ServerResponse = try await mockManager.sendGameResult(result)
        
        // Then
        #expect(mockManager.lastReceivedResult?.playerName == "Test Player")
        #expect(mockManager.lastReceivedResult?.result == .win)
        #expect(response.status == "success")
    }
    
    @Test func testSendGameResultFailure() async {
        // Given
        let mockManager = MockNetworkManager()
        mockManager.shouldSucceed = false
        
        // When/Then
        await #expect(throws: NetworkError.self) {
            let result = GameResult(
                playerId: UUID().uuidString,
                playerName: "Test Player",
                result: .lose,
                streak: 0,
                timestamp: Date()
            )
            _ = try await mockManager.sendGameResult(result)
        }
    }
}
