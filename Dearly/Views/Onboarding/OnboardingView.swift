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
            // Warm gradient background
            LinearGradient(
                colors: [
                    Color(red: 1.0, green: 0.97, blue: 0.95),
                    Color(red: 0.99, green: 0.95, blue: 0.93),
                    Color(red: 1.0, green: 0.98, blue: 0.96)
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            
            TabView(selection: $currentPage) {
                OnboardingPage1(currentPage: $currentPage)
                    .tag(0)
                
                OnboardingPage2(currentPage: $currentPage)
                    .tag(1)
                
                OnboardingPage3(currentPage: $currentPage, isOnboardingComplete: $isOnboardingComplete)
                    .tag(2)
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
            
            // Custom page indicator
            VStack {
                Spacer()
                HStack(spacing: 8) {
                    ForEach(0..<3, id: \.self) { index in
                        Capsule()
                            .fill(currentPage == index ? 
                                  Color(red: 0.85, green: 0.55, blue: 0.55) : 
                                  Color(red: 0.85, green: 0.55, blue: 0.55).opacity(0.3))
                            .frame(width: currentPage == index ? 24 : 8, height: 8)
                            .animation(.spring(response: 0.3), value: currentPage)
                    }
                }
                .padding(.bottom, 50)
            }
        }
        .preferredColorScheme(.light)
    }
}

#Preview {
    OnboardingView(isOnboardingComplete: .constant(false))
}
