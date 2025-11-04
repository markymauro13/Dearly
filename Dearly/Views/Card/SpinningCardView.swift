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
    
    @State private var isFlipped = false
    @State private var hasPerformedInitialFlip = false

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Front of the card (shows when not flipped)
                CardFrontView(card: card, width: geometry.size.width)
                    .rotation3DEffect(.degrees(isFlipped ? 0 : -90), axis: (x: 0, y: 1, z: 0))
                    .animation(isFlipped ? .easeInOut(duration: 0.35).delay(0.35) : .easeInOut(duration: 0.35), value: isFlipped)
                
                // Back of the card (shows when flipped)
                CardBackView(card: card, width: geometry.size.width)
                    .rotation3DEffect(.degrees(isFlipped ? 90 : 0), axis: (x: 0, y: 1, z: 0))
                    .animation(isFlipped ? .easeInOut(duration: 0.35) : .easeInOut(duration: 0.35).delay(0.35), value: isFlipped)
            }
            .onTapGesture(count: 2) {
                onDoubleTap?()
            }
            .onTapGesture {
                isFlipped.toggle()
            }
            .onAppear {
                // Perform one initial flip to show both sides exist
                if !hasPerformedInitialFlip {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        withAnimation {
                            isFlipped = true
                        }
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                            withAnimation {
                                isFlipped = false
                            }
                        }
                        hasPerformedInitialFlip = true
                    }
                }
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
                    .cornerRadius(12)
            } else {
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.gray.opacity(0.2))
                    .frame(width: width, height: width * 1.4)
                    .overlay(
                        Image(systemName: "photo")
                            .foregroundColor(.gray)
                    )
            }
        }
        .shadow(color: .black.opacity(0.2), radius: 8, x: 0, y: 4)
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
                    .cornerRadius(12)
                    .rotation3DEffect(
                        .degrees(180),
                        axis: (x: 0, y: 1, z: 0)
                    )
            } else {
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.gray.opacity(0.4))
                    .frame(width: width, height: width * 1.4)
                    .overlay(
                        Image(systemName: "questionmark")
                            .foregroundColor(.white)
                    )
                    .rotation3DEffect(
                        .degrees(180),
                        axis: (x: 0, y: 1, z: 0)
                    )
            }
        }
        .shadow(color: .black.opacity(0.2), radius: 8, x: 0, y: 4)
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
