//
//  OnboardingPage3.swift
//  Dearly
//
//  Created by Mark Mauro on 10/28/25.
//

import SwiftUI

struct OnboardingPage3: View {
    @Binding var currentPage: Int
    
    var body: some View {
        VStack(spacing: 0) {
            Spacer()
            
            // Categories illustration
            VStack(spacing: 16) {
                HStack(spacing: 12) {
                    CategoryPill(title: "Birthday", icon: "gift.fill", color: Color(red: 0.90, green: 0.55, blue: 0.60))
                    CategoryPill(title: "Thank You", icon: "heart.fill", color: Color(red: 0.85, green: 0.60, blue: 0.55))
                }
                HStack(spacing: 12) {
                    CategoryPill(title: "Congrats", icon: "star.fill", color: Color(red: 0.75, green: 0.65, blue: 0.55))
                    CategoryPill(title: "Holiday", icon: "snowflake", color: Color(red: 0.55, green: 0.70, blue: 0.80))
                }
                HStack(spacing: 12) {
                    CategoryPill(title: "Just Because", icon: "sparkles", color: Color(red: 0.70, green: 0.60, blue: 0.75))
                }
            }
            .padding(.bottom, 40)
            
            // Title
            Text("Dearly")
                .font(.custom("Snell Roundhand", size: 52))
                .foregroundColor(Color(red: 0.35, green: 0.28, blue: 0.28))
            
            Text("Organize & Cherish")
                .font(.system(size: 18, weight: .medium, design: .rounded))
                .foregroundColor(Color(red: 0.55, green: 0.48, blue: 0.48))
                .padding(.top, 4)
            
            Spacer()
            
            // Description
            Text("Sort by occasion, favorite the special ones,\nand find any memory in seconds.")
                .font(.system(size: 18, weight: .regular, design: .rounded))
                .foregroundColor(Color(red: 0.45, green: 0.40, blue: 0.40))
                .multilineTextAlignment(.center)
                .lineSpacing(6)
                .padding(.horizontal, 40)
            
            Spacer()
            
            // Button
            Button(action: {
                let impact = UIImpactFeedbackGenerator(style: .light)
                impact.impactOccurred()
                withAnimation(.spring(response: 0.4)) {
                    currentPage = 3
                }
            }) {
                Text("Continue")
                    .font(.system(size: 17, weight: .semibold, design: .rounded))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 18)
                    .background(
                        LinearGradient(
                            colors: [
                                Color(red: 0.88, green: 0.55, blue: 0.55),
                                Color(red: 0.78, green: 0.45, blue: 0.50)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .cornerRadius(16)
                    .shadow(color: Color(red: 0.85, green: 0.50, blue: 0.50).opacity(0.35), radius: 12, y: 6)
            }
            .padding(.horizontal, 40)
            .padding(.bottom, 100)
        }
    }
}

struct CategoryPill: View {
    let title: String
    let icon: String
    let color: Color
    
    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(color)
            
            Text(title)
                .font(.system(size: 14, weight: .semibold, design: .rounded))
                .foregroundColor(Color(red: 0.35, green: 0.30, blue: 0.30))
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(
            Capsule()
                .fill(Color.white)
                .shadow(color: color.opacity(0.2), radius: 8, y: 4)
        )
        .overlay(
            Capsule()
                .strokeBorder(color.opacity(0.3), lineWidth: 1)
        )
    }
}

#Preview {
    ZStack {
        Color(red: 1.0, green: 0.97, blue: 0.95).ignoresSafeArea()
        OnboardingPage3(currentPage: .constant(2))
    }
}
