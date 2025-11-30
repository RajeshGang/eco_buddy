//
//  FirebaseManager.swift
//  EcoBuddyWatch
//
//  Firebase configuration and setup
//

import Foundation
import FirebaseCore
import FirebaseFirestore
import FirebaseAuth

class FirebaseManager {
    static let shared = FirebaseManager()
    private let db = Firestore.firestore()
    
    private init() {}
    
    func getFirestore() -> Firestore {
        return db
    }
}

