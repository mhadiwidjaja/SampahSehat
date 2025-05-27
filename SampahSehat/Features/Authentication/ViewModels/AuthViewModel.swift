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
    private var firebaseAuthService = FirebaseAuthService()
    private var firestoreService = FirestoreService()

    @Published var currentUser: User? = nil

    @Published var isLoading: Bool = false

    @Published var authError: String? = nil

    init() {
        if let authId = firebaseAuthService.getCurrentUserAuthId() {
            Task {
                self.currentUser = await firestoreService.getUser(userId: authId)
            }
        }
    }

    func login(email: String, pass: String) {
        isLoading = true
        authError = nil
        Task {
            do {
                try await firebaseAuthService.login(email: email, pass: pass)
                if let authId = firebaseAuthService.getCurrentUserAuthId() {
                    self.currentUser = await firestoreService.getUser(userId: authId)
                    if self.currentUser == nil {
                        self.authError = "User profile not found."
                        try? firebaseAuthService.logout()
                    }
                } else {
                    self.authError = "Login failed. Please try again."
                }
            } catch {
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
        do {
            try firebaseAuthService.logout()
            self.currentUser = nil
        } catch {
            self.authError = "Logout failed: \(error.localizedDescription)"
        }
    }
}
