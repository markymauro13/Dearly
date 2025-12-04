//
//  CardItemView.swift
//  Dearly
//
//  Created by Mark Mauro on 10/28/25.
//

import SwiftUI
import SwiftData

struct CardItemView: View {
    let card: Card
    var onTap: (() -> Void)?
    var onFavoriteToggle: (() -> Void)?
    
    @State private var isPressed = false

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Front of the card
                CardFrontView(card: card, width: geometry.size.width)
                
                // Favorite heart overlay with warm glow
                VStack {
                    HStack {
                        Spacer()
                        Button(action: {
                            let impact = UIImpactFeedbackGenerator(style: .light)
                            impact.impactOccurred()
                            onFavoriteToggle?()
                        }) {
                            ZStack {
                                // Glow effect when favorited
                                if card.isFavorite {
                                    Circle()
                                        .fill(Color(red: 1.0, green: 0.5, blue: 0.5).opacity(0.3))
                                        .frame(width: 36, height: 36)
                                        .blur(radius: 8)
                                }
                                
                                Image(systemName: card.isFavorite ? "heart.fill" : "heart")
                                    .font(.system(size: 18, weight: .semibold))
                                    .foregroundColor(card.isFavorite ? Color(red: 0.95, green: 0.45, blue: 0.50) : .white)
                                    .shadow(color: .black.opacity(0.25), radius: 3, x: 0, y: 1)
                                    .scaleEffect(card.isFavorite ? 1.15 : 1.0)
                                    .animation(.spring(response: 0.35, dampingFraction: 0.5), value: card.isFavorite)
                            }
                            .padding(10)
                        }
                    }
                    Spacer()
                }
                .padding(6)
            }
            .scaleEffect(isPressed ? 0.98 : 1.0)
            .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isPressed)
            .onTapGesture {
                // Haptic feedback
                let impact = UIImpactFeedbackGenerator(style: .medium)
                impact.impactOccurred()
                
                // Press animation
                isPressed = true
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    isPressed = false
                }
                
                // Call the tap handler
                onTap?()
            }
        }
        .aspectRatio(1/1.4, contentMode: .fit)
    }
}

// MARK: - Card Front View
struct CardFrontView: View {
    let card: Card
    let width: CGFloat
    
    var body: some View {
        Group {
            if let frontImage = card.frontImage {
                Image(uiImage: frontImage)
                    .resizable()
                    .scaledToFill()
                    .frame(width: width, height: width * 1.4)
                    .clipped()
                    .cornerRadius(4)
                    .overlay(
                        Rectangle()
                            .strokeBorder(Color.white.opacity(0.15), lineWidth: 0.5)
                            .cornerRadius(4)
                    )
            } else {
                Rectangle()
                    .fill(
                        LinearGradient(
                            colors: [
                                Color(red: 0.98, green: 0.96, blue: 0.95),
                                Color(red: 0.95, green: 0.92, blue: 0.90)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: width, height: width * 1.4)
                    .cornerRadius(4)
                    .overlay(
                        VStack(spacing: 8) {
                            Image(systemName: "heart")
                                .font(.system(size: 24))
                                .foregroundColor(Color(red: 0.75, green: 0.65, blue: 0.65).opacity(0.5))
                        }
                    )
            }
        }
        .shadow(color: Color(red: 0.5, green: 0.4, blue: 0.4).opacity(0.15), radius: 12, x: 0, y: 6)
        .shadow(color: Color(red: 0.3, green: 0.2, blue: 0.2).opacity(0.08), radius: 3, x: 0, y: 1)
    }
}

// MARK: - Card Back View
struct CardBackView: View {
    let card: Card
    let width: CGFloat
    
    var body: some View {
        Group {
            if let backImage = card.backImage {
                Image(uiImage: backImage)
                    .resizable()
                    .scaledToFill()
                    .frame(width: width, height: width * 1.4)
                    .clipped()
                    .cornerRadius(4)
                    .rotation3DEffect(
                        .degrees(180),
                        axis: (x: 0, y: 1, z: 0)
                    )
            } else {
                Rectangle()
                    .fill(Color.gray.opacity(0.1))
                    .frame(width: width, height: width * 1.4)
                    .cornerRadius(4)
                    .overlay(
                        Image(systemName: "questionmark")
                            .foregroundColor(.gray.opacity(0.4))
                    )
                    .rotation3DEffect(
                        .degrees(180),
                        axis: (x: 0, y: 1, z: 0)
                    )
            }
        }
        .shadow(color: Color(red: 0.5, green: 0.4, blue: 0.4).opacity(0.15), radius: 12, x: 0, y: 6)
        .shadow(color: Color(red: 0.3, green: 0.2, blue: 0.2).opacity(0.08), radius: 3, x: 0, y: 1)
    }
}

#Preview {
    ZStack {
        Color.black.ignoresSafeArea()
        CardItemView(card: Card())
            .padding()
            .frame(height: 350)
    }
    .modelContainer(for: Card.self, inMemory: true)
}
