//
//  NetworkManager.swift
//  TicTacToe
//
//  Created by Максим on 17.07.2025.
//

import Foundation

protocol NetworkServiceProtocol {
    // MARK: - Game Specific Methods
    func sendGameResult(_ result: GameResult) async throws -> ServerResponse
}

final class NetworkManager: NetworkServiceProtocol {

    static let shared = NetworkManager()
    private let baseURL = "https://api.yourdomain.com/v1"
    private let urlSession: URLSession
    
    private init(urlSession: URLSession = .shared) {
        self.urlSession = urlSession
    }
    
    // MARK: - Public Methods
    func sendGameResult(_ result: GameResult) async throws -> ServerResponse {
        try await request(GameEndpoint.sendGameResult(result))
    }
    
    // MARK: - Private Core Method
    private func request<T: Decodable>(_ endpoint: EndpointProtocol) async throws -> T {
        
        let request = try buildRequest(for: endpoint)
        let (data, response) = try await urlSession.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw NetworkError.invalidResponse
        }
        
        guard (200...299).contains(httpResponse.statusCode) else {
            let errorData = try? JSONDecoder().decode(ErrorResponse.self, from: data)
            throw NetworkError.serverError(
                statusCode: httpResponse.statusCode,
                message: errorData?.message ?? "Unknown error"
            )
        }
        
        do {
            return try JSONDecoder().decode(T.self, from: data)
        } catch {
            throw NetworkError.decodingError(error)
        }
    }
    
    private func buildRequest(for endpoint: EndpointProtocol) throws -> URLRequest {
        guard let url = URL(string: baseURL)?.appendingPathComponent(endpoint.path) else {
            throw NetworkError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = endpoint.method
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        if let body = endpoint.body {
            request.httpBody = try JSONEncoder().encode(body)
        }
        
        return request
    }
}

struct ServerResponse: Decodable {
    let status: String
    let message: String?
}

struct ErrorResponse: Decodable {
    let message: String
    let code: Int
}
