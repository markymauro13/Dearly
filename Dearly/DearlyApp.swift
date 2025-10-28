//
//  DearlyApp.swift
//  Dearly
//
//  Created by Mark Mauro on 10/27/25.
//

import SwiftUI

@main
struct DearlyApp: App {
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = false
    
    var body: some Scene {
        WindowGroup {
            if hasCompletedOnboarding {
                HomeView()
            } else {
                OnboardingView(isOnboardingComplete: $hasCompletedOnboarding)
            }
        }
    }
}
