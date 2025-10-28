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
        VStack(spacing: 20) {
            Spacer()
            
            Text("Dearly")
                .font(.system(size: 44, weight: .bold))
                .padding(.top, 40)
            
            Spacer()
            
            VStack(alignment: .leading, spacing: 10) {
                HStack {
                    Image(systemName: "square.stack.3d.up.fill")
                        .foregroundColor(.gray)
                    Text("Save all cards from your loved ones - no limits!")
                        .font(.system(size: 15))
                }
                
                HStack {
                    Image(systemName: "square.stack.3d.up.fill")
                        .foregroundColor(.gray)
                    Text("Beautiful animations")
                        .font(.system(size: 15))
                }
                
                HStack {
                    Image(systemName: "heart.fill")
                        .foregroundColor(.gray)
                    Text("No charge until trial ends!")
                        .font(.system(size: 15))
                }
            }
            .padding(.horizontal, 40)
            
            Spacer()
            
            // Pricing options
            VStack(spacing: 12) {
                // Weekly plan
                Button(action: {
                    selectedPlan = .weekly
                }) {
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Weekly")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(.black)
                            Text("$1.99 paid yearly")
                                .font(.system(size: 12))
                                .foregroundColor(.gray)
                        }
                        Spacer()
                        Text("$1.99 / wk")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(.black)
                    }
                    .padding()
                    .background(selectedPlan == .weekly ? Color.white.opacity(0.2) : Color.white)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(selectedPlan == .weekly ? Color.blue : Color.gray.opacity(0.3), lineWidth: 2)
                    )
                    .cornerRadius(12)
                }
                
                // Lifetime plan
                Button(action: {
                    selectedPlan = .lifetime
                }) {
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Lifetime")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(.white)
                            Text("$24.99 paid yearly")
                                .font(.system(size: 12))
                                .foregroundColor(.white.opacity(0.8))
                        }
                        Spacer()
                        Text("$24.99")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(.white)
                    }
                    .padding()
                    .background(selectedPlan == .lifetime ? Color.blue : Color.gray.opacity(0.3))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(selectedPlan == .lifetime ? Color.blue : Color.gray.opacity(0.3), lineWidth: 2)
                    )
                    .cornerRadius(12)
                }
            }
            .padding(.horizontal, 40)
            
            Spacer()
            
            Button(action: {
                isOnboardingComplete = true
            }) {
                Text("Start Free Trial")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(.black)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(Color.gray.opacity(0.2))
                    .cornerRadius(12)
            }
            .padding(.horizontal, 40)
            
            Spacer()
        }
        .padding()
    }
}

#Preview {
    OnboardingPage4(isOnboardingComplete: .constant(false))
}

