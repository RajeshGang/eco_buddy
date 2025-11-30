//
//  LeaderboardView.swift
//  EcoBuddyWatch
//
//  Leaderboard view showing top users and user's rank
//

import SwiftUI

struct LeaderboardView: View {
    @EnvironmentObject var authManager: AuthManager
    @StateObject private var service = LeaderboardService()
    
    var body: some View {
        ScrollView {
            VStack(spacing: 8) {
                // User Stats Card
                if let userId = authManager.userId {
                    UserStatsCard(
                        rank: service.userRank,
                        points: service.userPoints
                    )
                    .padding(.horizontal)
                    
                    Divider()
                        .padding(.vertical, 4)
                }
                
                // Top Users
                VStack(alignment: .leading, spacing: 4) {
                    Text("Top Users")
                        .font(.headline)
                        .padding(.horizontal)
                    
                    if service.isLoading {
                        ProgressView()
                            .padding()
                    } else if service.topUsers.isEmpty {
                        Text("No data available")
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .padding()
                    } else {
                        ForEach(Array(service.topUsers.enumerated()), id: \.element.id) { index, entry in
                            LeaderboardRow(
                                rank: index + 1,
                                name: entry.displayName,
                                points: entry.totalPoints
                            )
                        }
                    }
                }
                .padding(.horizontal)
            }
        }
        .navigationTitle("Leaderboard")
        .onAppear {
            service.fetchTopUsers(limit: 10)
            if let userId = authManager.userId {
                service.fetchUserStats(userId: userId)
            }
        }
    }
}

struct UserStatsCard: View {
    let rank: Int?
    let points: Int
    
    var body: some View {
        VStack(spacing: 4) {
            HStack {
                Text("Your Rank")
                    .font(.caption)
                    .foregroundColor(.secondary)
                Spacer()
                if let rank = rank {
                    Text("#\(rank)")
                        .font(.title3)
                        .fontWeight(.bold)
                        .foregroundColor(.green)
                } else {
                    Text("--")
                        .font(.title3)
                        .foregroundColor(.secondary)
                }
            }
            
            HStack {
                Text("Points")
                    .font(.caption)
                    .foregroundColor(.secondary)
                Spacer()
                Text("\(points)")
                    .font(.title3)
                    .fontWeight(.bold)
            }
        }
        .padding()
        .background(Color.green.opacity(0.1))
        .cornerRadius(8)
    }
}

struct LeaderboardRow: View {
    let rank: Int
    let name: String
    let points: Int
    
    var body: some View {
        HStack {
            // Rank badge
            ZStack {
                Circle()
                    .fill(rank <= 3 ? Color.green : Color.gray.opacity(0.3))
                    .frame(width: 24, height: 24)
                Text("\(rank)")
                    .font(.caption2)
                    .fontWeight(.bold)
                    .foregroundColor(rank <= 3 ? .white : .primary)
            }
            
            // Name
            Text(name)
                .font(.caption)
                .lineLimit(1)
            
            Spacer()
            
            // Points
            Text("\(points)")
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundColor(.green)
        }
        .padding(.vertical, 2)
    }
}

#Preview {
    LeaderboardView()
        .environmentObject(AuthManager())
}

