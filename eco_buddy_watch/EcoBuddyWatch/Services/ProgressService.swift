//
//  ProgressService.swift
//  EcoBuddyWatch
//
//  Service for fetching progress/trends data
//

import Foundation
import FirebaseFirestore

struct ReceiptScore: Identifiable {
    let id: String
    let score: Double
    let date: Date
}

struct ProgressStats {
    let averageScore: Double
    let bestScore: Int
    let totalReceipts: Int
}

class ProgressService: ObservableObject {
    private let db = FirebaseManager.shared.getFirestore()
    
    @Published var recentScores: [ReceiptScore] = []
    @Published var stats: ProgressStats?
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    func fetchProgress(userId: String, period: TimePeriod) {
        isLoading = true
        errorMessage = nil
        
        let startDate = getStartDate(for: period)
        
        db.collection("users")
            .document(userId)
            .collection("receipts")
            .whereField("timestamp", isGreaterThan: Timestamp(date: startDate))
            .order(by: "timestamp", descending: true)
            .limit(to: 20)
            .getDocuments { [weak self] snapshot, error in
                DispatchQueue.main.async {
                    self?.isLoading = false
                    
                    if let error = error {
                        self?.errorMessage = error.localizedDescription
                        return
                    }
                    
                    guard let documents = snapshot?.documents else {
                        self?.recentScores = []
                        self?.stats = nil
                        return
                    }
                    
                    let scores = documents.compactMap { doc -> ReceiptScore? in
                        let data = doc.data()
                        guard let score = data["overallScore"] as? Double,
                              let timestamp = data["timestamp"] as? Timestamp else {
                            return nil
                        }
                        
                        return ReceiptScore(
                            id: doc.documentID,
                            score: score,
                            date: timestamp.dateValue()
                        )
                    }
                    
                    self?.recentScores = scores
                    self?.calculateStats(scores: scores)
                }
            }
    }
    
    private func calculateStats(scores: [ReceiptScore]) {
        guard !scores.isEmpty else {
            stats = nil
            return
        }
        
        let average = scores.map { $0.score }.reduce(0, +) / Double(scores.count)
        let best = Int(scores.map { $0.score }.max() ?? 0)
        let total = scores.count
        
        stats = ProgressStats(
            averageScore: average,
            bestScore: best,
            totalReceipts: total
        )
    }
    
    private func getStartDate(for period: TimePeriod) -> Date {
        let calendar = Calendar.current
        let now = Date()
        
        switch period {
        case .week:
            return calendar.date(byAdding: .day, value: -7, to: now) ?? now
        case .month:
            return calendar.date(byAdding: .day, value: -30, to: now) ?? now
        case .year:
            return calendar.date(byAdding: .day, value: -365, to: now) ?? now
        }
    }
}

enum TimePeriod: String, CaseIterable {
    case week = "Week"
    case month = "Month"
    case year = "Year"
}

