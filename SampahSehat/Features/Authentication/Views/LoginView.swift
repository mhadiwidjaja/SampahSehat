//
//  LoginView.swift
//  SampahSehat
//
//  Created by student on 27/05/25.
//

import SwiftUI

struct LoginView: View {
    // Use shared instance instead of creating new one
    @ObservedObject private var authViewModel = AuthViewModel.shared
    @State private var email = ""
    @State private var password = ""

    @State private var navigateToCollectorView = false

    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                Text("SampahSehat Collector Login")
                    .font(.largeTitle)
                
                Text("Use: collector@test.com / 123456")
                    .font(.caption)
                    .foregroundColor(.gray)

                TextField("Email", text: $email)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .keyboardType(.emailAddress)
                    .autocapitalization(.none)

                SecureField("Password", text: $password)
                    .textFieldStyle(RoundedBorderTextFieldStyle())

                if authViewModel.isLoading {
                    ProgressView("Logging in...")
                } else {
                    Button("Login") {
                        print("🔵 Login button pressed with email: \(email)")
                        authViewModel.login(email: email, pass: password)
                    }
                    .padding()
                    .buttonStyle(.borderedProminent)
                    .disabled(email.isEmpty || password.isEmpty)
                }

                if let error = authViewModel.authError {
                    Text(error)
                        .foregroundColor(.red)
                        .font(.caption)
                }

                // Debug info
                if let user = authViewModel.currentUser {
                    Text("✅ Logged in as: \(user.email)")
                        .font(.caption2)
                        .foregroundColor(.green)
                } else {
                    Text("❌ Not logged in")
                        .font(.caption2)
                        .foregroundColor(.red)
                }

                NavigationLink(destination: CollectorScheduleListView().environmentObject(CollectorViewModel()),
                               isActive: $navigateToCollectorView) {
                    EmptyView()
                }
            }
            .padding()
            .onAppear {
                // Clear navigation state when returning to login
                navigateToCollectorView = false
                print("🔵 LoginView appeared - clearing navigation state")
                print("🔵 Current user in LoginView: \(authViewModel.currentUser?.email ?? "nil")")
            }
            .onChange(of: authViewModel.currentUser) { user in
                print("🔄 User state changed in LoginView: \(user?.email ?? "nil")")
                if let user = user, user.role == "Collector" {
                    print("✅ Valid collector user - navigating to collector view")
                    navigateToCollectorView = true
                } else {
                    print("❌ No valid user - staying on login")
                    navigateToCollectorView = false
                }
            }
        }
    }
}

struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView()
    }
}
