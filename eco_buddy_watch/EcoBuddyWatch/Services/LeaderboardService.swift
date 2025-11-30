//
//  LeaderboardService.swift
//  EcoBuddyWatch
//
//  Service for fetching leaderboard data
//

import Foundation
import FirebaseFirestore
import Combine

class LeaderboardService: ObservableObject {
    private let db = FirebaseManager.shared.getFirestore()
    
    @Published var topUsers: [LeaderboardEntry] = []
    @Published var userRank: Int?
    @Published var userPoints: Int = 0
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private var cancellables = Set<AnyCancellable>()
    
    func fetchTopUsers(limit: Int = 10) {
        isLoading = true
        errorMessage = nil
        
        db.collection("leaderboard")
            .order(by: "totalPoints", descending: true)
            .limit(to: limit)
            .addSnapshotListener { [weak self] snapshot, error in
                DispatchQueue.main.async {
                    self?.isLoading = false
                    
                    if let error = error {
                        self?.errorMessage = error.localizedDescription
                        return
                    }
                    
                    guard let documents = snapshot?.documents else {
                        self?.topUsers = []
                        return
                    }
                    
                    self?.topUsers = documents.compactMap { doc in
                        let data = doc.data()
                        guard let displayName = data["displayName"] as? String,
                              let totalPoints = data["totalPoints"] as? Int else {
                            return nil
                        }
                        
                        let lastUpdated: Date
                        if let timestamp = data["lastUpdated"] as? Timestamp {
                            lastUpdated = timestamp.dateValue()
                        } else {
                            lastUpdated = Date()
                        }
                        
                        return LeaderboardEntry(
                            id: doc.documentID,
                            displayName: displayName,
                            totalPoints: totalPoints,
                            lastUpdated: lastUpdated
                        )
                    }
                }
            }
    }
    
    func fetchUserStats(userId: String) {
        isLoading = true
        errorMessage = nil
        
        // Fetch user points
        db.collection("leaderboard")
            .document(userId)
            .getDocument { [weak self] document, error in
                DispatchQueue.main.async {
                    if let error = error {
                        self?.errorMessage = error.localizedDescription
                        self?.isLoading = false
                        return
                    }
                    
                    if let data = document?.data() {
                        self?.userPoints = data["totalPoints"] as? Int ?? 0
                    }
                    
                    // Calculate rank
                    self?.calculateRank(userId: userId, userPoints: self?.userPoints ?? 0)
                }
            }
    }
    
    private func calculateRank(userId: String, userPoints: Int) {
        db.collection("leaderboard")
            .whereField("totalPoints", isGreaterThan: userPoints)
            .count
            .getAggregation(source: .server) { [weak self] snapshot, error in
                DispatchQueue.main.async {
                    self?.isLoading = false
                    
                    if let error = error {
                        self?.errorMessage = error.localizedDescription
                        return
                    }
                    
                    let higherCount = snapshot?.count?.intValue ?? 0
                    self?.userRank = higherCount + 1
                }
            }
    }
}

