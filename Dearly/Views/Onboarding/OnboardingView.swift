//
//  OnboardingView.swift
//  Dearly
//
//  Created by Mark Mauro on 10/28/25.
//

import SwiftUI

struct OnboardingView: View {
    @State private var currentPage = 0
    @Binding var isOnboardingComplete: Bool
    
    var body: some View {
        ZStack {
            TabView(selection: $currentPage) {
                OnboardingPage1(currentPage: $currentPage)
                    .tag(0)
                
                OnboardingPage2(currentPage: $currentPage)
                    .tag(1)
                
                OnboardingPage3(currentPage: $currentPage)
                    .tag(2)
                
                OnboardingPage4(isOnboardingComplete: $isOnboardingComplete)
                    .tag(3)
            }
            .tabViewStyle(.page(indexDisplayMode: .always))
            .indexViewStyle(.page(backgroundDisplayMode: .always))
        }
    }
}

#Preview {
    OnboardingView(isOnboardingComplete: .constant(false))
}
