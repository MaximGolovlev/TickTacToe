//
//  Endpoint.swift
//  TicTacToe
//
//  Created by Максим on 17.07.2025.
//

import Foundation

protocol EndpointProtocol {
    var path: String { get }
    var method: String { get }
    var body: Encodable? { get }
    var headers: [String: String]? { get }
}

enum GameEndpoint: EndpointProtocol {
    case sendGameResult(GameResult)
    
    var path: String {
        switch self {
        case .sendGameResult:
            return "/game/results"
        }
    }
    
    var method: String {
        switch self {
        case .sendGameResult:
            return "POST"
        }
    }
    
    var body: Encodable? {
        switch self {
        case .sendGameResult(let result):
            return result
        }
    }
    
    var headers: [String: String]? {
        ["App-Version": Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? ""]
    }
}
