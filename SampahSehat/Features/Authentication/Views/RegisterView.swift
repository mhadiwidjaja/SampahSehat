//
//  RegisterView.swift
//  SampahSehat
//
//  Created by student on 27/05/25.
//

import SwiftUI

struct RegisterView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @Environment(\.presentationMode) var presentationMode

    @State private var email = ""
    @State private var password = ""
    @State private var confirmPassword = ""

    @State private var showAlert = false
    @State private var alertMessage = ""

    var body: some View {
        VStack(spacing: 20) {
            Text("Register New Account")
                .font(.largeTitle)

            TextField("Email", text: $email)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .keyboardType(.emailAddress)
                .autocapitalization(.none)

            SecureField("Password", text: $password)
                .textFieldStyle(RoundedBorderTextFieldStyle())

            SecureField("Confirm Password", text: $confirmPassword)
                .textFieldStyle(RoundedBorderTextFieldStyle())

            if authViewModel.isLoading {
                ProgressView()
            } else {
                Button("Register") {
                    performRegistration()
                }
                .padding()
                .buttonStyle(.borderedProminent)
                .disabled(password != confirmPassword || email.isEmpty || password.isEmpty)
            }
            if let error = authViewModel.authError, !showAlert {
                Text(error)
                    .foregroundColor(.red)
                    .padding(.top)
            }
        }
        .padding()
        .navigationTitle("Register")
        .alert(isPresented: $showAlert) {
            Alert(
                title: Text(authViewModel.currentUser != nil && authViewModel.authError == nil ? "Registration Successful" : "Registration Failed"),
                message: Text(alertMessage),
                dismissButton: .default(Text("OK")) {
                    if authViewModel.currentUser != nil && authViewModel.authError == nil {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
            )
        }
    }

    private func performRegistration() {
        if password != confirmPassword {
            alertMessage = "Passwords do not match."
            showAlert = true
            return
        }
        authViewModel.authError = nil

        authViewModel.signUp(email: email, pass: password)
        
        Task {
            try? await Task.sleep(nanoseconds: 500_000_000)

            if authViewModel.currentUser != nil && authViewModel.authError == nil {
                alertMessage = "Account created successfully! You are now logged in. Please complete your profile if prompted elsewhere."
            } else {
                alertMessage = authViewModel.authError ?? "An unknown error occurred during registration."
            }
            showAlert = true
        }
    }
}

struct RegisterView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            RegisterView().environmentObject(AuthViewModel())
        }
    }
}
