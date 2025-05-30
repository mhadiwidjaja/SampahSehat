//
//  SampahSehatApp.swift
//  SampahSehat
//
//  Created by student on 27/05/25.
//

import SwiftUI
import FirebaseCore

@main
struct SampahSehatApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    
    class FirebaseManager {
        static var hasConfigured = false
        static func configure() {
            if !hasConfigured {
                FirebaseApp.configure()
                hasConfigured = true
            }
        }
    }
    
    var body: some Scene {
        WindowGroup {
            LoginView()
        }
    }
}
