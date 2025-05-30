//
//  LoginView.swift
//  SampahSehat
//
//  Created by student on 27/05/25.
//

import SwiftUI

struct LoginView: View {
    @StateObject private var authViewModel = AuthViewModel()
    @State private var email = ""          // Start empty - no auto-fill
    @State private var password = ""       // Start empty - no auto-fill

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
                        authViewModel.login(email: email, pass: password)
                    }
                    .padding()
                    .buttonStyle(.borderedProminent)
                    .disabled(email.isEmpty || password.isEmpty) // Disable if fields are empty
                }

                if let error = authViewModel.authError {
                    Text(error)
                        .foregroundColor(.red)
                        .font(.caption)
                }

                NavigationLink(destination: CollectorScheduleListView().environmentObject(CollectorViewModel()),
                               isActive: $navigateToCollectorView) {
                    EmptyView()
                }
            }
            .padding()
            .onChange(of: authViewModel.currentUser) { user in
                if let user = user, user.role == "Collector" {
                    navigateToCollectorView = true
                } else {
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
