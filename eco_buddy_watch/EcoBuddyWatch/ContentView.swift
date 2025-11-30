//
//  ContentView.swift
//  EcoBuddyWatch
//
//  Main navigation view for the watch app
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var authManager: AuthManager
    @State private var selectedTab = 0
    
    var body: some View {
        TabView(selection: $selectedTab) {
            // Leaderboard Tab
            LeaderboardView()
                .tag(0)
            
            // Progress Tab
            ProgressView()
                .tag(1)
            
            // Profile Tab
            ProfileView()
                .tag(2)
        }
        .tabViewStyle(.page)
        .onAppear {
            authManager.checkAuthStatus()
        }
    }
}

#Preview {
    ContentView()
        .environmentObject(AuthManager())
}

