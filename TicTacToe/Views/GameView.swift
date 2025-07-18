//
//  ContentView.swift
//  TicTacToe
//
//  Created by Максим on 17.07.2025.
//

import SwiftUI
import CoreData

struct GameView: View {
    @StateObject private var viewModel: GameViewModel
    @State private var showLeaderboard = false
    
    init(playerName: String) {
        _viewModel = StateObject(wrappedValue: GameViewModel(playerName: playerName))
    }
    
    var body: some View {
        VStack {
            
            Spacer()
            
            if viewModel.gameOver {
                gameOver
            } else {
                board
            }
            
            Spacer()
            
        }
        .padding([.leading, .trailing])
        .navigationTitle("Tic Tac Toe")
        .sheet(isPresented: $showLeaderboard) {
            LeaderboardView()
        }
    }
    
    var board: some View {
        Group {
            Text("\(viewModel.currentPlayer == .human ? "Your turn" : "AI thinking...")")
                .font(.title)
                .padding()
            
            LazyVGrid(columns: Array(repeating: GridItem(.fixed(80)), count: 3), spacing: 10) {
                ForEach(0..<9, id: \.self) { index in
                    cell(index: index)
                }
            }
            .padding()
        }
    }
    
    func cell(index: Int) -> some View {
        Button(action: {
            viewModel.makeMove(at: index)
        }) {
            Text(viewModel.board[index] ?? "")
                .font(.system(size: 40))
                .frame(width: 80, height: 80)
                .background(
                    viewModel.board[index] == nil
                    ? .appPrimary.opacity(0.3)
                    : .appPrimary.opacity(0.1)
                )
                .cornerRadius(10)
        }
        .disabled(viewModel.board[index] != nil ||
                  viewModel.gameOver ||
                  viewModel.currentPlayer != .human ||
                  viewModel.isComputerThinking)
    }
    
    var gameOver: some View {
        Group {
            if let result = viewModel.result {
                Group {
                    switch result {
                    case .win:
                        Text("You won!")
                    case .lose:
                        Text("You lost!")
                    case .draw:
                        Text("Draw!")
                    }
                }
                .font(.title)
                .padding()
            }
            
            Button(action: {
                viewModel.resetGame()
            }) {
                Text("Reset game")
                    .frame(maxWidth: .infinity)
            }
            .padding()
            .background(.appPrimary)
            .foregroundStyle(.white)
            .clipShape(.buttonBorder)
        }
    }
}

#Preview {
    GameView(playerName: "Maxim")
}
