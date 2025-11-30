//
//  AuthManager.swift
//  EcoBuddyWatch
//
//  Manages authentication state
//

import Foundation
import FirebaseAuth
import Combine

class AuthManager: ObservableObject {
    @Published var isAuthenticated = false
    @Published var currentUser: User?
    @Published var userId: String?
    
    private var authStateListener: AuthStateDidChangeListenerHandle?
    
    init() {
        checkAuthStatus()
    }
    
    func checkAuthStatus() {
        authStateListener = Auth.auth().addStateDidChangeListener { [weak self] _, user in
            DispatchQueue.main.async {
                self?.currentUser = user
                self?.isAuthenticated = user != nil
                self?.userId = user?.uid
            }
        }
    }
    
    deinit {
        if let listener = authStateListener {
            Auth.auth().removeStateDidChangeListener(listener)
        }
    }
}

