//
//  EcoBuddyWatchApp.swift
//  EcoBuddyWatch
//
//  Apple Watch companion app for EcoBuddy
//

import SwiftUI
import FirebaseCore

@main
struct EcoBuddyWatchApp: App {
    @StateObject private var authManager = AuthManager()
    
    init() {
        // Initialize Firebase
        FirebaseApp.configure()
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(authManager)
        }
    }
}

