//
//  FirebaseAuthService.swift
//  SampahSehat
//
//  Created by student on 27/05/25.
//

import Foundation
import FirebaseAuth

class FirebaseAuthService {
    private var auth = Auth.auth()

    func login(email: String, pass: String) async throws -> User? {
        let authResult = try await auth.signIn(withEmail: email, password: pass)
        return nil
    }
    
    func signUp(email: String, pass: String) async throws -> User? {
        let authResult = try await auth.createUser(withEmail: email, password: pass)
        return nil
    }

    func logout() throws {
        try auth.signOut()
    }

    func getCurrentUserAuthId() -> String? {
        return auth.currentUser?.uid
    }
}
