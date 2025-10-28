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
        VStack(spacing: 30) {
            Spacer()
            
            Text("Dearly")
                .font(.system(size: 44, weight: .bold))
                .padding(.top, 40)
            
            Spacer()
            
            Text("Categorize and sort to organize and rank your faves!")
                .font(.system(size: 20, weight: .medium))
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
            
            // Card categories
            VStack(spacing: 15) {
                HStack(spacing: 20) {
                    CategoryBadge(title: "bday")
                    CategoryBadge(title: "congrats")
                }
                HStack(spacing: 20) {
                    CategoryBadge(title: "get well")
                    CategoryBadge(title: "thank you")
                }
            }
            .padding(.vertical, 30)
            
            Image(systemName: "medal.fill")
                .resizable()
                .scaledToFit()
                .frame(width: 80, height: 80)
                .foregroundColor(.yellow)
            
            Spacer()
            
            Button(action: {
                withAnimation {
                    currentPage = 3
                }
            }) {
                Text("Continue")
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
    OnboardingPage3(currentPage: .constant(2))
}

