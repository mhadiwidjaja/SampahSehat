//
//  FirebaseAuthService.swift
//  SampahSehat
//
//  Created by student on 27/05/25.
//

import Foundation
import FirebaseAuth

class FirebaseAuthService {
    // Singleton instance - shared across the app
    static let shared = FirebaseAuthService()
    
    private var auth = Auth.auth()
    
    // Track login state properly - make this a class-level property
    private var isLoggedIn = false
    private var loggedInUserId: String? = nil
    
    // Private initializer to prevent multiple instances
    private init() {}

    func login(email: String, pass: String) async throws -> User? {
        // For dummy data, we'll simulate login with predefined collector
        if email == "collector@test.com" && pass == "12345678" {
            // Mark as logged in and store user ID
            isLoggedIn = true
            loggedInUserId = "collector123"
            
            // Return a dummy collector user
            return User(
                userId: "collector123",
                email: email,
                locationInfo: "Jakarta Area",
                role: "Collector"
            )
        } else {
            isLoggedIn = false
            loggedInUserId = nil
            throw NSError(domain: "AuthError", code: 1, userInfo: [NSLocalizedDescriptionKey: "Invalid credentials. Use collector@test.com with password 123456"])
        }
    }
    
    func signUp(email: String, pass: String) async throws -> User? {
        let authResult = try await auth.createUser(withEmail: email, password: pass)
        return nil
    }

    func logout() throws {
        try auth.signOut()
        // Clear login state
        isLoggedIn = false
        loggedInUserId = nil
    }

    func getCurrentUserAuthId() -> String? {
        // Only return user ID if actually logged in
        return isLoggedIn ? loggedInUserId : nil
    }
}
