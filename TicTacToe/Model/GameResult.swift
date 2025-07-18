//
//  GameResults.swift
//  TicTacToe
//
//  Created by Максим on 17.07.2025.
//

import Foundation

struct GameResult: Encodable {
    let playerId: String?
    let playerName: String?
    let result: GameOutcome
    let streak: Int
    let timestamp: Date
}

enum GameOutcome: String, Encodable {
    case win, lose, draw
}
