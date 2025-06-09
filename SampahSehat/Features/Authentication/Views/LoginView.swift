//
//  LoginView.swift
//  SampahSehat
//
//  Created by student on 27/05/25.
//

import SwiftUI

struct LoginView: View {
    @ObservedObject private var authViewModel = AuthViewModel.shared
    @State private var email = ""
    @State private var password = ""
    @State private var navigateToCollectorView = false

    var body: some View {
        NavigationStack {
            GeometryReader { geometry in
                ScrollView {
                    VStack(spacing: 0) {
                        // Header Section with Logo
                        VStack(spacing: 30) {
                            Spacer(minLength: geometry.size.height * 0.08)
                            
                            // Logo with elegant styling
                            VStack(spacing: 20) {
                                Image("SampahSehat")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 100, height: 100)
                                    .clipShape(RoundedRectangle(cornerRadius: 22))
                                    .shadow(color: .green.opacity(0.3), radius: 15, x: 0, y: 8)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 22)
                                            .stroke(
                                                LinearGradient(
                                                    colors: [.green.opacity(0.3), .blue.opacity(0.3)],
                                                    startPoint: .topLeading,
                                                    endPoint: .bottomTrailing
                                                ),
                                                lineWidth: 2
                                            )
                                    )
                                
                                VStack(spacing: 8) {
                                    Text("SampahSehat")
                                        .font(.system(size: 34, weight: .bold, design: .rounded))
                                        .foregroundStyle(
                                            LinearGradient(
                                                colors: [.green, .blue],
                                                startPoint: .leading,
                                                endPoint: .trailing
                                            )
                                        )
                                    
                                    Text("Collector Portal")
                                        .font(.title2)
                                        .fontWeight(.medium)
                                        .foregroundColor(.secondary)
                                }
                            }
                        }
                        
                        // Login Form Section
                        VStack(spacing: 25) {
                            VStack(spacing: 20) {
                                // Demo Credentials Card
                                VStack(spacing: 12) {
                                    HStack {
                                        Image(systemName: "info.circle.fill")
                                            .foregroundColor(.blue)
                                        Text("Demo Credentials")
                                            .font(.headline)
                                            .fontWeight(.semibold)
                                        Spacer()
                                    }
                                    
                                    VStack(alignment: .leading, spacing: 6) {
                                        Text("Email: collector@test.com")
                                            .font(.subheadline)
                                            .foregroundColor(.secondary)
                                        Text("Password: 12345678")
                                            .font(.subheadline)
                                            .foregroundColor(.secondary)
                                    }
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                }
                                .padding(16)
                                .background(Color.blue.opacity(0.08))
                                .cornerRadius(12)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(Color.blue.opacity(0.2), lineWidth: 1)
                                )
                                
                                // Email Input
                                VStack(alignment: .leading, spacing: 8) {
                                    HStack {
                                        Image(systemName: "envelope.fill")
                                            .foregroundColor(.green)
                                            .frame(width: 20)
                                        Text("Email Address")
                                            .font(.headline)
                                            .fontWeight(.semibold)
                                    }
                                    
                                    TextField("Enter your email", text: $email)
                                        .font(.body)
                                        .padding(16)
                                        .background(Color(.systemGray6))
                                        .cornerRadius(12)
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 12)
                                                .stroke(email.isEmpty ? Color.clear : Color.green, lineWidth: 2)
                                        )
                                        .keyboardType(.emailAddress)
                                        .autocapitalization(.none)
                                }
                                
                                // Password Input
                                VStack(alignment: .leading, spacing: 8) {
                                    HStack {
                                        Image(systemName: "lock.fill")
                                            .foregroundColor(.green)
                                            .frame(width: 20)
                                        Text("Password")
                                            .font(.headline)
                                            .fontWeight(.semibold)
                                    }
                                    
                                    SecureField("Enter your password", text: $password)
                                        .font(.body)
                                        .padding(16)
                                        .background(Color(.systemGray6))
                                        .cornerRadius(12)
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 12)
                                                .stroke(password.isEmpty ? Color.clear : Color.green, lineWidth: 2)
                                        )
                                }
                            }
                            
                            // Login Button
                            if authViewModel.isLoading {
                                HStack {
                                    ProgressView()
                                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                        .scaleEffect(0.8)
                                    Text("Signing In...")
                                        .font(.headline)
                                        .fontWeight(.semibold)
                                }
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding(18)
                                .background(
                                    LinearGradient(
                                        colors: [.green, .blue],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                                .cornerRadius(16)
                            } else {
                                Button(action: {
                                    authViewModel.login(email: email, pass: password)
                                }) {
                                    HStack {
                                        Image(systemName: "person.crop.circle.fill")
                                        Text("Sign In")
                                            .font(.headline)
                                            .fontWeight(.semibold)
                                    }
                                    .foregroundColor(.white)
                                    .frame(maxWidth: .infinity)
                                    .padding(18)
                                    .background(
                                        LinearGradient(
                                            colors: email.isEmpty || password.isEmpty ?
                                                [.gray, .gray] : [.green, .blue],
                                            startPoint: .leading,
                                            endPoint: .trailing
                                        )
                                    )
                                    .cornerRadius(16)
                                    .shadow(color: .green.opacity(0.3), radius: 8, x: 0, y: 4)
                                }
                                .disabled(email.isEmpty || password.isEmpty)
                                .scaleEffect(email.isEmpty || password.isEmpty ? 0.95 : 1.0)
                                .animation(.easeInOut(duration: 0.2), value: email.isEmpty || password.isEmpty)
                            }
                            
                            // Error Message
                            if let error = authViewModel.authError {
                                HStack {
                                    Image(systemName: "exclamationmark.triangle.fill")
                                        .foregroundColor(.red)
                                    Text(error)
                                        .font(.subheadline)
                                        .foregroundColor(.red)
                                }
                                .padding(12)
                                .background(Color.red.opacity(0.1))
                                .cornerRadius(8)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 8)
                                        .stroke(Color.red.opacity(0.3), lineWidth: 1)
                                )
                            }
                        }
                        .padding(.horizontal, 30)
                        .padding(.top, 40)
                        
                        Spacer(minLength: 50)
                        
                        NavigationLink(
                            destination: CollectorScheduleListView().environmentObject(CollectorViewModel()),
                            isActive: $navigateToCollectorView
                        ) {
                            EmptyView()
                        }
                    }
                }
            }
            .background(
                LinearGradient(
                    colors: [Color(.systemBackground), Color(.systemGray6).opacity(0.3)],
                    startPoint: .top,
                    endPoint: .bottom
                )
            )
            .onAppear {
                navigateToCollectorView = false
            }
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
