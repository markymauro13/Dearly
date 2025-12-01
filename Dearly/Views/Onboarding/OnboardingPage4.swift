//
//  OnboardingPage4.swift
//  Dearly
//
//  Created by Mark Mauro on 10/28/25.
//

import SwiftUI

struct OnboardingPage4: View {
    @Binding var isOnboardingComplete: Bool
    @State private var selectedPlan: PricingPlan = .lifetime
    
    enum PricingPlan {
        case weekly, lifetime
    }
    
    var body: some View {
        VStack(spacing: 0) {
            Spacer()
            
            // Premium icon
            ZStack {
                Circle()
                    .fill(Color(red: 0.95, green: 0.88, blue: 0.88).opacity(0.5))
                    .frame(width: 100, height: 100)
                    .blur(radius: 20)
                
                Image(systemName: "sparkles")
                    .font(.system(size: 50))
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
            }
            .padding(.bottom, 24)
            
            // Title
            Text("Dearly")
                .font(.custom("Snell Roundhand", size: 44))
                .foregroundColor(Color(red: 0.35, green: 0.28, blue: 0.28))
            
            Text("Premium")
                .font(.system(size: 16, weight: .semibold, design: .rounded))
                .foregroundColor(Color(red: 0.85, green: 0.55, blue: 0.55))
                .padding(.top, 2)
            
            Spacer()
            
            // Features
            VStack(alignment: .leading, spacing: 16) {
                FeatureRow(icon: "infinity", text: "Unlimited card storage")
                FeatureRow(icon: "cube.transparent", text: "Beautiful 3D card viewer")
                FeatureRow(icon: "heart.fill", text: "Favorite & organize your collection")
                FeatureRow(icon: "icloud.fill", text: "Automatic cloud backup")
            }
            .padding(.horizontal, 40)
            
            Spacer()
            
            // Pricing options
            VStack(spacing: 12) {
                // Weekly plan
                PlanOption(
                    title: "Weekly",
                    subtitle: "Billed weekly",
                    price: "$1.99/wk",
                    isSelected: selectedPlan == .weekly,
                    isPrimary: false
                ) {
                    selectedPlan = .weekly
                }
                
                // Lifetime plan
                PlanOption(
                    title: "Lifetime",
                    subtitle: "One-time purchase",
                    price: "$24.99",
                    isSelected: selectedPlan == .lifetime,
                    isPrimary: true,
                    badge: "Best Value"
                ) {
                    selectedPlan = .lifetime
                }
            }
            .padding(.horizontal, 24)
            
            Spacer()
            
            // CTA Button
            Button(action: {
                let impact = UIImpactFeedbackGenerator(style: .medium)
                impact.impactOccurred()
                isOnboardingComplete = true
            }) {
                Text("Start Free Trial")
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
            
            // Trial info
            Text("7 days free, then \(selectedPlan == .weekly ? "$1.99/week" : "$24.99 once")")
                .font(.system(size: 13, design: .rounded))
                .foregroundColor(Color(red: 0.55, green: 0.50, blue: 0.50))
                .padding(.top, 12)
            
            // Restore purchases
            Button("Restore Purchases") {
                // Handle restore
            }
            .font(.system(size: 13, weight: .medium, design: .rounded))
            .foregroundColor(Color(red: 0.55, green: 0.50, blue: 0.50))
            .padding(.top, 8)
            .padding(.bottom, 100)
        }
    }
}

struct FeatureRow: View {
    let icon: String
    let text: String
    
    var body: some View {
        HStack(spacing: 14) {
            Image(systemName: icon)
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(Color(red: 0.85, green: 0.55, blue: 0.55))
                .frame(width: 24)
            
            Text(text)
                .font(.system(size: 16, weight: .medium, design: .rounded))
                .foregroundColor(Color(red: 0.35, green: 0.30, blue: 0.30))
        }
    }
}

struct PlanOption: View {
    let title: String
    let subtitle: String
    let price: String
    let isSelected: Bool
    let isPrimary: Bool
    var badge: String? = nil
    let action: () -> Void
    
    var body: some View {
        Button(action: {
            let impact = UIImpactFeedbackGenerator(style: .light)
            impact.impactOccurred()
            action()
        }) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    HStack(spacing: 8) {
                        Text(title)
                            .font(.system(size: 16, weight: .semibold, design: .rounded))
                            .foregroundColor(isPrimary && isSelected ? .white : Color(red: 0.30, green: 0.25, blue: 0.25))
                        
                        if let badge = badge {
                            Text(badge)
                                .font(.system(size: 10, weight: .bold, design: .rounded))
                                .foregroundColor(.white)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 3)
                                .background(Color(red: 0.90, green: 0.55, blue: 0.55))
                                .cornerRadius(6)
                        }
                    }
                    
                    Text(subtitle)
                        .font(.system(size: 12, design: .rounded))
                        .foregroundColor(isPrimary && isSelected ? .white.opacity(0.8) : Color(red: 0.55, green: 0.50, blue: 0.50))
                }
                
                Spacer()
                
                Text(price)
                    .font(.system(size: 17, weight: .bold, design: .rounded))
                    .foregroundColor(isPrimary && isSelected ? .white : Color(red: 0.30, green: 0.25, blue: 0.25))
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 18)
            .background(
                Group {
                    if isPrimary && isSelected {
                        LinearGradient(
                            colors: [
                                Color(red: 0.85, green: 0.55, blue: 0.55),
                                Color(red: 0.75, green: 0.45, blue: 0.50)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    } else {
                        Color.white
                    }
                }
            )
            .cornerRadius(16)
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .strokeBorder(
                        isSelected ? Color(red: 0.85, green: 0.55, blue: 0.55) : Color(red: 0.90, green: 0.87, blue: 0.85),
                        lineWidth: isSelected ? 2 : 1
                    )
            )
            .shadow(color: isSelected ? Color(red: 0.85, green: 0.55, blue: 0.55).opacity(0.2) : Color.black.opacity(0.05), radius: 8, y: 4)
        }
    }
}

#Preview {
    ZStack {
        Color(red: 1.0, green: 0.97, blue: 0.95).ignoresSafeArea()
        OnboardingPage4(isOnboardingComplete: .constant(false))
    }
}
