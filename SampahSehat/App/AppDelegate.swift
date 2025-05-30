//
//  AppDelegate.swift
//  SampahSehat
//
//  Created by student on 27/05/25.
//

import UIKit
import FirebaseCore

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        print("AppDelegate: didFinishLaunchingWithOptions - Configuring Firebase...")
        FirebaseApp.configure()
        print("AppDelegate: Firebase configured!")
        return true
    }
}
