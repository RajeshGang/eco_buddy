//
//  ProfileView.swift
//  EcoBuddyWatch
//
//  Profile view showing user information
//

import SwiftUI
import FirebaseAuth

struct ProfileView: View {
    @EnvironmentObject var authManager: AuthManager
    
    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                if let user = authManager.currentUser {
                    // User info
                    VStack(spacing: 8) {
                        Image(systemName: "person.circle.fill")
                            .font(.system(size: 50))
                            .foregroundColor(.green)
                        
                        Text(user.displayName ?? user.email ?? "User")
                            .font(.headline)
                            .lineLimit(1)
                        
                        if let email = user.email {
                            Text(email)
                                .font(.caption)
                                .foregroundColor(.secondary)
                                .lineLimit(1)
                        }
                    }
                    .padding()
                    
                    Divider()
                    
                    // Account info
                    VStack(alignment: .leading, spacing: 12) {
                        InfoRow(
                            icon: "checkmark.seal.fill",
                            label: "Account Status",
                            value: "Active"
                        )
                        
                        InfoRow(
                            icon: "calendar",
                            label: "Member Since",
                            value: formatDate(user.metadata.creationDate)
                        )
                    }
                    .padding(.horizontal)
                } else {
                    VStack(spacing: 12) {
                        Image(systemName: "person.circle")
                            .font(.system(size: 50))
                            .foregroundColor(.secondary)
                        
                        Text("Not Signed In")
                            .font(.headline)
                        
                        Text("Sign in on your iPhone to sync data")
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                    }
                    .padding()
                }
            }
        }
        .navigationTitle("Profile")
    }
    
    private func formatDate(_ date: Date?) -> String {
        guard let date = date else { return "Unknown" }
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: date)
    }
}

struct InfoRow: View {
    let icon: String
    let label: String
    let value: String
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(.green)
                .frame(width: 20)
            
            Text(label)
                .font(.caption)
                .foregroundColor(.secondary)
            
            Spacer()
            
            Text(value)
                .font(.caption)
                .fontWeight(.medium)
        }
    }
}

#Preview {
    ProfileView()
        .environmentObject(AuthManager())
}

