//
//  OnboardingPage1.swift
//  Dearly
//
//  Created by Mark Mauro on 10/28/25.
//

import SwiftUI

struct OnboardingPage1: View {
    @Binding var currentPage: Int
    
    var body: some View {
        VStack(spacing: 30) {
            Spacer()
            
            Text("Dearly")
                .font(.system(size: 44, weight: .bold))
                .padding(.top, 40)
            
            Spacer()
            
            Text("The card app to help manage and view your cards from loved ones.")
                .font(.system(size: 20, weight: .medium))
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
            
            // Placeholder for card collage image
            Image(systemName: "photo.on.rectangle.angled")
                .resizable()
                .scaledToFit()
                .frame(width: 200, height: 200)
                .foregroundColor(.gray.opacity(0.3))
                .padding(.vertical, 30)
            
            Spacer()
            
            Button(action: {
                withAnimation {
                    currentPage = 1
                }
            }) {
                Text("Get Started")
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
    OnboardingPage1(currentPage: .constant(0))
}

