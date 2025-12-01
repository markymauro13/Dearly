//
//  OnboardingPage2.swift
//  Dearly
//
//  Created by Mark Mauro on 10/28/25.
//

import SwiftUI

struct OnboardingPage2: View {
    @Binding var currentPage: Int
    @State private var cardOffset: CGFloat = 0
    
    var body: some View {
        VStack(spacing: 0) {
            Spacer()
            
            // Scanning illustration
            ZStack {
                // Card stack
                ForEach(0..<3, id: \.self) { i in
                    RoundedRectangle(cornerRadius: 8)
                        .fill(
                            LinearGradient(
                                colors: [
                                    Color(red: 1.0, green: 0.98, blue: 0.96),
                                    Color(red: 0.98, green: 0.95, blue: 0.93)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 120, height: 160)
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .strokeBorder(Color(red: 0.90, green: 0.85, blue: 0.83), lineWidth: 1)
                        )
                        .shadow(color: Color(red: 0.5, green: 0.4, blue: 0.4).opacity(0.1), radius: 8, y: 4)
                        .rotationEffect(.degrees(Double(i - 1) * 8))
                        .offset(y: CGFloat(i) * -5)
                }
                
                // Camera viewfinder overlay
                ZStack {
                    RoundedRectangle(cornerRadius: 12)
                        .strokeBorder(Color(red: 0.85, green: 0.55, blue: 0.55), lineWidth: 3)
                        .frame(width: 140, height: 180)
                    
                    // Corner brackets
                    VStack {
                        HStack {
                            CornerBracket()
                            Spacer()
                            CornerBracket().rotationEffect(.degrees(90))
                        }
                        Spacer()
                        HStack {
                            CornerBracket().rotationEffect(.degrees(-90))
                            Spacer()
                            CornerBracket().rotationEffect(.degrees(180))
                        }
                    }
                    .frame(width: 150, height: 190)
                }
                .offset(y: cardOffset)
                .animation(
                    Animation.easeInOut(duration: 1.5).repeatForever(autoreverses: true),
                    value: cardOffset
                )
            }
            .frame(height: 220)
            .padding(.bottom, 40)
            .onAppear { cardOffset = -8 }
            
            // Title
            Text("Dearly")
                .font(.custom("Snell Roundhand", size: 52))
                .foregroundColor(Color(red: 0.35, green: 0.28, blue: 0.28))
            
            Text("Scan & Preserve")
                .font(.system(size: 18, weight: .medium, design: .rounded))
                .foregroundColor(Color(red: 0.55, green: 0.48, blue: 0.48))
                .padding(.top, 4)
            
            Spacer()
            
            // Description
            Text("Capture every detail with our smart scanner.\nFront, back, and inside — all preserved perfectly.")
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
                    currentPage = 2
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

// Corner bracket for scanner effect
struct CornerBracket: View {
    var body: some View {
        Path { path in
            path.move(to: CGPoint(x: 0, y: 15))
            path.addLine(to: CGPoint(x: 0, y: 0))
            path.addLine(to: CGPoint(x: 15, y: 0))
        }
        .stroke(Color(red: 0.85, green: 0.55, blue: 0.55), lineWidth: 3)
        .frame(width: 15, height: 15)
    }
}

#Preview {
    ZStack {
        Color(red: 1.0, green: 0.97, blue: 0.95).ignoresSafeArea()
        OnboardingPage2(currentPage: .constant(1))
    }
}
