//
//  DearlyApp.swift
//  Dearly
//
//  Created by Mark Mauro on 10/27/25.
//

import SwiftUI
import SwiftData

@main
struct DearlyApp: App {
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = false
    
    init() {
        // Clean up legacy UserDefaults data from old storage system
        clearLegacyUserDefaultsData()
    }
    
    var body: some Scene {
        WindowGroup {
            if hasCompletedOnboarding {
                HomeView()
            } else {
                OnboardingView(isOnboardingComplete: $hasCompletedOnboarding)
            }
        }
        .modelContainer(for: Card.self)
    }
    
    /// Removes old UserDefaults data that was used before SwiftData migration
    private func clearLegacyUserDefaultsData() {
        let legacyKey = "savedCards"
        if UserDefaults.standard.data(forKey: legacyKey) != nil {
            UserDefaults.standard.removeObject(forKey: legacyKey)
            print("✅ Cleared legacy UserDefaults card data")
        }
    }
}
