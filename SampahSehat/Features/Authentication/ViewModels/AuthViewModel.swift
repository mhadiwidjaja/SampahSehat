//
//  AuthViewModel.swift
//  SampahSehat
//
//  Created by student on 27/05/25.
//

import SwiftUI
import FirebaseAuth

@MainActor
class AuthViewModel: ObservableObject {
    // Singleton instance - shared across the app
    static let shared = AuthViewModel()
    
    // Use shared instance instead of creating new one
    private var firebaseAuthService = FirebaseAuthService.shared
    private var firestoreService = FirestoreService()

    @Published var currentUser: User? = nil
    @Published var isLoading: Bool = false
    @Published var authError: String? = nil

    // Private initializer to prevent multiple instances
    private init() {
        print("🔧 AuthViewModel initialized")
        // Only load user if there's an existing auth session
        if let authId = firebaseAuthService.getCurrentUserAuthId() {
            print("🔍 Found existing auth ID: \(authId)")
            Task {
                self.currentUser = await firestoreService.getUser(userId: authId)
            }
        } else {
            print("🔍 No existing auth ID found")
        }
    }

    func login(email: String, pass: String) {
        print("🔐 AuthViewModel.login called")
        isLoading = true
        authError = nil
        Task {
            do {
                // Try to login and get user data directly
                if let user = try await firebaseAuthService.login(email: email, pass: pass) {
                    print("✅ AuthViewModel: Login successful, setting currentUser")
                    self.currentUser = user
                } else {
                    print("❌ AuthViewModel: Login returned nil user")
                    self.authError = "Login failed. Please try again."
                }
            } catch {
                print("❌ AuthViewModel: Login error: \(error.localizedDescription)")
                self.authError = error.localizedDescription
            }
            isLoading = false
        }
    }

    func signUp(email: String, pass: String) {
        isLoading = true
        authError = nil
        Task {
            do {
                try await firebaseAuthService.signUp(email: email, pass: pass)
                if let authId = firebaseAuthService.getCurrentUserAuthId() {
                    self.currentUser = await firestoreService.getUser(userId: authId)
                     if self.currentUser == nil {
                        print("New user signed up. User document needs to be created in Firestore with role, locationInfo.")
                        self.authError = "Sign up successful. Profile setup needed."
                    }
                } else {
                     self.authError = "Sign up failed. Please try again."
                }
            } catch {
                self.authError = error.localizedDescription
            }
            isLoading = false
        }
    }

    func logout() {
        print("🚪 AuthViewModel.logout called")
        do {
            try firebaseAuthService.logout()
            self.currentUser = nil
            print("✅ AuthViewModel: Logout successful - currentUser set to nil")
        } catch {
            self.authError = "Logout failed: \(error.localizedDescription)"
            print("❌ AuthViewModel: Logout error: \(error.localizedDescription)")
        }
    }
}
