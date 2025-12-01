//
//  OnboardingPage1.swift
//  Dearly
//
//  Created by Mark Mauro on 10/28/25.
//

import SwiftUI

struct OnboardingPage1: View {
    @Binding var currentPage: Int
    @State private var animate = false
    
    var body: some View {
        VStack(spacing: 0) {
            Spacer()
            
            // Animated hearts background
            ZStack {
                // Floating hearts
                ForEach(0..<5, id: \.self) { i in
                    Image(systemName: "heart.fill")
                        .font(.system(size: CGFloat.random(in: 16...28)))
                        .foregroundColor(Color(red: 0.90, green: 0.60, blue: 0.60).opacity(Double.random(in: 0.2...0.4)))
                        .offset(
                            x: CGFloat.random(in: -120...120),
                            y: animate ? CGFloat.random(in: -80...80) : CGFloat.random(in: -60...60)
                        )
                        .animation(
                            Animation.easeInOut(duration: Double.random(in: 3...5))
                                .repeatForever(autoreverses: true)
                                .delay(Double(i) * 0.3),
                            value: animate
                        )
                }
                
                // Main heart icon
                ZStack {
                    Circle()
                        .fill(Color(red: 0.95, green: 0.88, blue: 0.88).opacity(0.6))
                        .frame(width: 160, height: 160)
                        .blur(radius: 30)
                    
                    Image(systemName: "heart.fill")
                        .font(.system(size: 80))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [
                                    Color(red: 0.92, green: 0.55, blue: 0.55),
                                    Color(red: 0.80, green: 0.45, blue: 0.50)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .shadow(color: Color(red: 0.85, green: 0.50, blue: 0.50).opacity(0.3), radius: 20, y: 10)
                }
            }
            .frame(height: 200)
            .padding(.bottom, 40)
            
            // Title
            Text("Dearly")
                .font(.custom("Snell Roundhand", size: 52))
                .foregroundColor(Color(red: 0.35, green: 0.28, blue: 0.28))
            
            Text("Cherish Every Card")
                .font(.system(size: 18, weight: .medium, design: .rounded))
                .foregroundColor(Color(red: 0.55, green: 0.48, blue: 0.48))
                .padding(.top, 4)
            
            Spacer()
            
            // Description
            Text("A beautiful home for the cards\nfrom the people you love most.")
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
                    currentPage = 1
                }
            }) {
                Text("Get Started")
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
        .onAppear { animate = true }
    }
}

#Preview {
    ZStack {
        Color(red: 1.0, green: 0.97, blue: 0.95).ignoresSafeArea()
        OnboardingPage1(currentPage: .constant(0))
    }
}
