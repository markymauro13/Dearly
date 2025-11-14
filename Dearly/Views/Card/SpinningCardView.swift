//
//  SpinningCardView.swift
//  Dearly
//
//  Created by Mark Mauro on 10/28/25.
//

import SwiftUI

struct SpinningCardView: View {
    let card: Card
    var onDoubleTap: (() -> Void)?
    var onFavoriteToggle: (() -> Void)?
    
    @State private var isFlipped = false
    @State private var isPressed = false

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Front of the card (shows when not flipped)
                CardFrontView(card: card, width: geometry.size.width)
                    .rotation3DEffect(.degrees(isFlipped ? -90 : 0), axis: (x: 0, y: 1, z: 0))
                    .animation(isFlipped ? .easeInOut(duration: 0.35) : .easeInOut(duration: 0.35).delay(0.35), value: isFlipped)
                
                // Back of the card (shows when flipped)
                CardBackView(card: card, width: geometry.size.width)
                    .rotation3DEffect(.degrees(isFlipped ? 0 : 90), axis: (x: 0, y: 1, z: 0))
                    .animation(isFlipped ? .easeInOut(duration: 0.35).delay(0.35) : .easeInOut(duration: 0.35), value: isFlipped)
                
                // Favorite heart overlay with pop animation
                VStack {
                    HStack {
                        Spacer()
                        Button(action: {
                            let impact = UIImpactFeedbackGenerator(style: .light)
                            impact.impactOccurred()
                            onFavoriteToggle?()
                        }) {
                            Image(systemName: card.isFavorite ? "heart.fill" : "heart")
                                .font(.system(size: 20, weight: .semibold))
                                .foregroundColor(card.isFavorite ? Color(red: 1.0, green: 0.54, blue: 0.54) : .white)
                                .shadow(color: .black.opacity(0.3), radius: 2, x: 0, y: 1)
                                .scaleEffect(card.isFavorite ? 1.1 : 1.0)
                                .animation(.spring(response: 0.3, dampingFraction: 0.6), value: card.isFavorite)
                                .padding(8)
                        }
                    }
                    Spacer()
                }
                .padding(8)
            }
            .scaleEffect(isPressed ? 0.98 : 1.0)
            .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isPressed)
            .onTapGesture(count: 2) {
                onDoubleTap?()
            }
            .onTapGesture {
                isPressed = true
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    isPressed = false
                }
                isFlipped.toggle()
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
                    .cornerRadius(24)
            } else {
                RoundedRectangle(cornerRadius: 24)
                    .fill(Color.gray.opacity(0.1))
                    .frame(width: width, height: width * 1.4)
                    .overlay(
                        Image(systemName: "photo")
                            .foregroundColor(.gray.opacity(0.4))
                    )
            }
        }
        .shadow(color: .black.opacity(0.08), radius: 12, x: 0, y: 4)
        .shadow(color: .black.opacity(0.04), radius: 4, x: 0, y: 2)
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
                    .cornerRadius(24)
                    .rotation3DEffect(
                        .degrees(180),
                        axis: (x: 0, y: 1, z: 0)
                    )
            } else {
                RoundedRectangle(cornerRadius: 24)
                    .fill(Color.gray.opacity(0.1))
                    .frame(width: width, height: width * 1.4)
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
        .shadow(color: .black.opacity(0.08), radius: 12, x: 0, y: 4)
        .shadow(color: .black.opacity(0.04), radius: 4, x: 0, y: 2)
    }
}

#Preview {
    ZStack {
        Color.black.ignoresSafeArea()
        SpinningCardView(card: Card(
            frontImageData: nil,
            backImageData: nil,
            insideLeftImageData: nil,
            insideRightImageData: nil
        ))
        .padding()
        .frame(height: 350)
    }
}
