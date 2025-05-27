//
//  LoginView.swift
//  SampahSehat
//
//  Created by student on 27/05/25.
//

import SwiftUI

struct LoginView: View {
    @StateObject private var authViewModel = AuthViewModel()
    @State private var email = ""
    @State private var password = ""

    @State private var navigateToCollectorView = false

    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                Text("SampahSehat Collector Login")
                    .font(.largeTitle)

                TextField("Email", text: $email)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .keyboardType(.emailAddress)
                    .autocapitalization(.none)

                SecureField("Password", text: $password)
                    .textFieldStyle(RoundedBorderTextFieldStyle())

                if authViewModel.isLoading {
                    ProgressView()
                } else {
                    Button("Login") {
                        authViewModel.login(email: email, pass: password)
                    }
                    .padding()
                    .buttonStyle(.borderedProminent)
                }

                if let error = authViewModel.authError {
                    Text(error)
                        .foregroundColor(.red)
                }
                NavigationLink("Create Account", destination: RegisterView().environmentObject(authViewModel))
                                    .padding(.top)

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
