//
//  CardDetailView.swift
//  Dearly
//
//  Created by Mark Mauro on 10/28/25.
//

import SwiftUI

struct CardDetailView: View {
    let card: Card
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            VStack {
                // Close button
                HStack {
                    Spacer()
                    Button(action: {
                        dismiss()
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 30))
                            .foregroundColor(.white.opacity(0.8))
                    }
                    .padding()
                }
                
                Spacer()
                
                // Animated Card
                AnimatedCardView(card: card)
                    .padding(.horizontal, 20)
                
                Spacer()
                
                // Instruction text
                Text("Tap to open card")
                    .font(.system(size: 16))
                    .foregroundColor(.white.opacity(0.6))
                    .padding(.bottom, 40)
            }
        }
    }
}

#Preview {
    CardDetailView(card: Card(
        frontImageData: nil,
        insideSpreadImageData: nil
    ))
}

