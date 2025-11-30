//
//  LeaderboardEntry.swift
//  EcoBuddyWatch
//
//  Model for leaderboard entries
//

import Foundation
import FirebaseFirestore

struct LeaderboardEntry: Identifiable {
    let id: String
    let displayName: String
    let totalPoints: Int
    let lastUpdated: Date
    
    init(id: String, displayName: String, totalPoints: Int, lastUpdated: Date) {
        self.id = id
        self.displayName = displayName
        self.totalPoints = totalPoints
        self.lastUpdated = lastUpdated
    }
}

