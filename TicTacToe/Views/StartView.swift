//
//  StartView.swift
//  TicTacToe
//
//  Created by Максим on 17.07.2025.
//

import SwiftUI

struct StartView: View {
    @State private var playerName = ""
    @State private var startGame = false
    @State private var showLeaderboard = false
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 16) {
                
                Spacer()
                
                TextField("Player name", text: $playerName)
                    .frame(maxWidth: .infinity, minHeight: 50)
                    .padding(.horizontal)
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(10)
                
                Button(action: {
                    startGame = !playerName.isEmpty
                }) {
                    Text("Start")
                        .frame(maxWidth: .infinity)
                }
                .padding()
                .background(playerName.isEmpty ? Color.gray : .appPrimary)
                .foregroundStyle(.white)
                .disabled(playerName.isEmpty)
                .clipShape(.buttonBorder)
                
                Button(action: {
                    showLeaderboard = true
                }) {
                    Text("Show rating")
                        .frame(maxWidth: .infinity)
                }
                .padding()
                .background(Color.green)
                .foregroundStyle(.white)
                .clipShape(.buttonBorder)
                
                Spacer()

            }
            .navigationDestination(isPresented: $startGame) {
                GameView(playerName: playerName)
            }
            .sheet(isPresented: $showLeaderboard) {
                LeaderboardView()
            }
            .padding()
            .navigationTitle("Log in")
        }
    }
}

#Preview {
    StartView()
}
