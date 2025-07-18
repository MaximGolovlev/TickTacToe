//
//  LeaderboardView.swift
//  TicTacToe
//
//  Created by Максим on 17.07.2025.
//

import SwiftUI

struct LeaderboardView: View {
    @FetchRequest(
        entity: Player.entity(),
        sortDescriptors: [
            NSSortDescriptor(keyPath: \Player.wins, ascending: false),
            NSSortDescriptor(keyPath: \Player.streak, ascending: false)
        ]
    ) var players: FetchedResults<Player>
    
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationView {
            List {
                ForEach(players, id: \.id) { player in
                    HStack {
                        VStack(alignment: .leading) {
                            Text(player.name ?? "Unknown")
                                .font(.headline)
                            
                            Text("Wins: \(player.wins), Losses: \(player.losses)")
                                .font(.subheadline)
                            
                            if player.wins > 0 || player.losses > 0 {
                                let ratio = Double(player.wins) / Double(player.wins + player.losses)
                                Text(String(format: "Ratio: %.1f%%", ratio * 100))
                                    .font(.caption)
                            }
                            
                            if player.streak > 0 {
                                Text("Winning Streak: \(player.streak)")
                                    .font(.caption)
                                    .foregroundColor(.green)
                            }
                            
                            if let lastWin = player.lastWinDate {
                                Text("Last win: \(lastWin.formatted())")
                                    .font(.caption2)
                            }
                        }
                        
                        Spacer()
                        
                        Text("\(player.wins)")
                            .font(.title)
                            .foregroundColor(.green)
                    }
                    .padding(.vertical, 4)
                }
            }
            .navigationTitle("Leader board")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Close") {
                        dismiss()
                    }
                }
            }
        }
    }
}
