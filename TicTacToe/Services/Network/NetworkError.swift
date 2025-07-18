//
//  NetworkError.swift
//  TicTacToe
//
//  Created by Максим on 17.07.2025.
//

enum NetworkError: Error {
    case invalidURL
    case invalidResponse
    case serverError(statusCode: Int, message: String)
    case decodingError(Error)
    case unauthorized
    case noInternetConnection
    case timeout
    
    var localizedDescription: String {
        switch self {
        case .invalidURL: 
            return "Invalid URL"
        case .invalidResponse:
            return "Invalid server response"
        case .serverError(let statusCode, let message):
            return "Server error \(statusCode): \(message)"
        case .decodingError(let error):
            return "Decoding error: \(error.localizedDescription)"
        case .unauthorized: 
            return "Authentication required"
        case .noInternetConnection: 
            return "No internet connection"
        case .timeout: 
            return "Request timeout"
        }
    }
}
