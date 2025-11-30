//
//  ProgressView.swift
//  EcoBuddyWatch
//
//  Progress view showing sustainability score trends
//

import SwiftUI

struct ProgressView: View {
    @EnvironmentObject var authManager: AuthManager
    @StateObject private var service = ProgressService()
    @State private var selectedPeriod: TimePeriod = .month
    
    var body: some View {
        ScrollView {
            VStack(spacing: 12) {
                // Period selector
                Picker("Period", selection: $selectedPeriod) {
                    Text("Week").tag(TimePeriod.week)
                    Text("Month").tag(TimePeriod.month)
                    Text("Year").tag(TimePeriod.year)
                }
                .pickerStyle(.segmented)
                .padding(.horizontal)
                
                // Stats summary
                if let stats = service.stats {
                    StatsSummaryCard(stats: stats)
                        .padding(.horizontal)
                }
                
                // Recent scores
                if service.recentScores.isEmpty {
                    VStack(spacing: 8) {
                        Image(systemName: "chart.line.uptrend.xyaxis")
                            .font(.largeTitle)
                            .foregroundColor(.secondary)
                        Text("No data yet")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .padding()
                } else {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Recent Scores")
                            .font(.headline)
                            .padding(.horizontal)
                        
                        ForEach(service.recentScores.prefix(5), id: \.id) { score in
                            ScoreRow(score: score)
                        }
                    }
                }
            }
        }
        .navigationTitle("Progress")
        .onAppear {
            if let userId = authManager.userId {
                service.fetchProgress(userId: userId, period: selectedPeriod)
            }
        }
        .onChange(of: selectedPeriod) { newPeriod in
            if let userId = authManager.userId {
                service.fetchProgress(userId: userId, period: newPeriod)
            }
        }
    }
}

struct StatsSummaryCard: View {
    let stats: ProgressStats
    
    var body: some View {
        VStack(spacing: 8) {
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text("Average")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                    Text(String(format: "%.1f", stats.averageScore))
                        .font(.title3)
                        .fontWeight(.bold)
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 2) {
                    Text("Best")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                    Text("\(stats.bestScore)")
                        .font(.title3)
                        .fontWeight(.bold)
                        .foregroundColor(.green)
                }
            }
        }
        .padding()
        .background(Color.blue.opacity(0.1))
        .cornerRadius(8)
    }
}

struct ScoreRow: View {
    let score: ReceiptScore
    
    var body: some View {
        HStack {
            Text(score.date, style: .date)
                .font(.caption2)
                .foregroundColor(.secondary)
            
            Spacer()
            
            Text("\(Int(score.score))")
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundColor(scoreColor(score.score))
        }
        .padding(.horizontal)
        .padding(.vertical, 4)
    }
    
    private func scoreColor(_ score: Double) -> Color {
        if score >= 75 { return .green }
        if score >= 50 { return .orange }
        return .red
    }
}

#Preview {
    ProgressView()
        .environmentObject(AuthManager())
}

