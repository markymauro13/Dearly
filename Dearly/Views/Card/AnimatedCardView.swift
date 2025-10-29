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
    private let cardWidth: CGFloat = 160
    private let cardHeight: CGFloat = 224

    // A private helper view to create each visual side of the card.
    private struct CardFace: View {
        let image: UIImage?
        let text: String
        let width: CGFloat
        let height: CGFloat

        var body: some View {
            Group {
                if let image = image {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFill()
                } else {
                    Rectangle()
                        .fill(Color.white)
                        .overlay(Text(text).foregroundColor(.black))
                }
            }
            .frame(width: width, height: height)
            .clipped()
        }
    }

    var body: some View {
        ZStack {
            // Base Layer: The fully open card, composed of the two inside pages.
            // This is always present but is only fully visible when the cover opens.
            HStack(spacing: 0) {
                CardFace(image: card.insideLeftImage, text: "Left", width: cardWidth, height: cardHeight)
                CardFace(image: card.insideRightImage, text: "Right", width: cardWidth, height: cardHeight)
            }
            .cornerRadius(16)
            .shadow(color: .black.opacity(0.3), radius: 10, y: 5)

            // Top Layer: The front cover, which acts as a "door".
            CardFace(image: card.frontImage, text: "Front", width: cardWidth, height: cardHeight)
                .cornerRadius(16)
                .shadow(color: .black.opacity(0.4), radius: 12, y: 8)
                // This rotation swings the cover open or closed.
                .rotation3DEffect(
                    .degrees(isOpen ? -180 : 0),
                    axis: (x: 0, y: 1, z: 0),
                    anchor: .leading, // The "hinge" or "spine" of the card.
                    perspective: 0.4
                )
        }
        // This offset is the key to the centering animation.
        // When closed, the view is shifted so the cover appears centered.
        // When open, the offset is removed, and the full two-page spread is centered.
        .offset(x: isOpen ? 0 : -cardWidth / 2)
        .onTapGesture {
            let impact = UIImpactFeedbackGenerator(style: .medium)
            impact.impactOccurred()
            
            // Use a spring animation for a more physical feel.
            withAnimation(.spring(response: 0.6, dampingFraction: 0.7)) {
                isOpen.toggle()
            }
        }
    }
}

#Preview {
    ZStack {
        Color.gray.ignoresSafeArea()
        AnimatedCardView(card: Card(
            frontImageData: nil,
            insideLeftImageData: nil,
            insideRightImageData: nil
        ))
        .padding()
    }
}
