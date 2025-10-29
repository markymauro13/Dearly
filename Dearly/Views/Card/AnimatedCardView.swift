//
//  AnimatedCardView.swift
//  Dearly
//
//  Created by Mark Mauro on 10/28/25.
//

import SwiftUI

struct AnimatedCardView: View {
    let card: Card
    
    @State private var isOpen = false
    
    var body: some View {
        ZStack {
            // Inside pages (static, always underneath)
            HStack(spacing: 0) {
                // Left inside page
                Group {
                    if let leftImage = card.insideLeftImage {
                        Image(uiImage: leftImage)
                            .resizable()
                            .scaledToFill()
                            .frame(width: 160, height: 224)
                            .clipped()
                    } else {
                        Rectangle()
                            .fill(Color.white)
                            .frame(width: 160, height: 224)
                            .overlay(Text("Left").foregroundColor(Color.black))
                    }
                }
                
                // Right inside page
                Group {
                    if let rightImage = card.insideRightImage {
                        Image(uiImage: rightImage)
                            .resizable()
                            .scaledToFill()
                            .frame(width: 160, height: 224)
                            .clipped()
                    } else {
                        Rectangle()
                            .fill(Color.white)
                            .frame(width: 160, height: 224)
                            .overlay(Text("Right").foregroundColor(Color.black))
                    }
                }
            }
            .cornerRadius(16)
            .shadow(color: Color.black.opacity(0.3), radius: 10, x: 0, y: 5)
            
            // Front cover (rotates to reveal inside)
            Group {
                if let frontImage = card.frontImage {
                    Image(uiImage: frontImage)
                        .resizable()
                        .scaledToFill()
                        .frame(width: 160, height: 224)
                        .clipped()
                } else {
                    Rectangle()
                        .fill(Color.white)
                        .frame(width: 160, height: 224)
                        .overlay(Text("Tap to Open").foregroundColor(Color.black))
                }
            }
            .cornerRadius(16)
            .shadow(color: Color.black.opacity(0.5), radius: 15, x: 0, y: 8)
            .rotation3DEffect(
                .degrees(isOpen ? -160 : 0),
                axis: (x: 0, y: 1, z: 0),
                anchor: .leading,
                perspective: 0.3
            )
            .opacity(isOpen ? 0 : 1)
        }
        .onTapGesture {
            let impact = UIImpactFeedbackGenerator(style: .medium)
            impact.impactOccurred()
            
            withAnimation(.spring(response: 0.8, dampingFraction: 0.7)) {
                isOpen.toggle()
            }
        }
    }
    
}

#Preview {
    ZStack {
        Color.black.ignoresSafeArea()
        AnimatedCardView(card: Card(
            frontImageData: nil,
            insideLeftImageData: nil,
            insideRightImageData: nil
        ))
        .padding()
    }
}

