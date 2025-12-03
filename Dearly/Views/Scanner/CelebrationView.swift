//
//  CelebrationView.swift
//  Dearly
//
//  Created by Mark Mauro on 10/28/25.
//

import SwiftUI

// MARK: - Celebration View
struct CelebrationView: View {
    let card: Card
    let onAddDetails: () -> Void
    let onScanAnother: () -> Void
    let onDone: () -> Void
    
    @State private var showConfetti = false
    @State private var cardScale: CGFloat = 0.5
    @State private var cardOpacity: Double = 0
    @State private var textOpacity: Double = 0
    @State private var buttonsOffset: CGFloat = 50
    @State private var buttonsOpacity: Double = 0
    
    var body: some View {
        ZStack {
            // Background
            LinearGradient(
                colors: [
                    Color(red: 1.0, green: 0.98, blue: 0.96),
                    Color(red: 0.99, green: 0.97, blue: 0.95)
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            
            // Confetti
            if showConfetti {
                ConfettiView()
                    .ignoresSafeArea()
            }
            
            VStack(spacing: 24) {
                Spacer()
                
                // Success checkmark with burst
                ZStack {
                    // Burst circles
                    ForEach(0..<8, id: \.self) { i in
                        Circle()
                            .fill(Color(red: 0.85, green: 0.55, blue: 0.55).opacity(0.3))
                            .frame(width: 12, height: 12)
                            .offset(y: showConfetti ? -60 : 0)
                            .rotationEffect(.degrees(Double(i) * 45))
                            .opacity(showConfetti ? 0 : 1)
                            .animation(
                                .easeOut(duration: 0.6).delay(0.1),
                                value: showConfetti
                            )
                    }
                    
                    // Main circle
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [
                                    Color(red: 0.40, green: 0.75, blue: 0.45),
                                    Color(red: 0.30, green: 0.65, blue: 0.40)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 100, height: 100)
                        .shadow(color: Color(red: 0.35, green: 0.70, blue: 0.40).opacity(0.4), radius: 20, x: 0, y: 10)
                        .scaleEffect(cardScale)
                    
                    Image(systemName: "checkmark")
                        .font(.system(size: 44, weight: .bold))
                        .foregroundColor(.white)
                        .scaleEffect(cardScale)
                }
                
                // Text
                VStack(spacing: 8) {
                    Text("Card Saved!")
                        .font(.system(size: 32, weight: .bold, design: .rounded))
                        .foregroundColor(Color(red: 0.25, green: 0.20, blue: 0.20))
                    
                    Text("Your memory has been preserved forever")
                        .font(.system(.body, design: .rounded))
                        .foregroundColor(.secondary)
                }
                .opacity(textOpacity)
                
                // Card preview
                if let frontImage = card.frontImage {
                    Image(uiImage: frontImage)
                        .resizable()
                        .scaledToFill()
                        .frame(width: 160, height: 200)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        .shadow(color: Color.black.opacity(0.15), radius: 20, x: 0, y: 10)
                        .rotationEffect(.degrees(-3))
                        .scaleEffect(cardScale)
                        .opacity(cardOpacity)
                }
                
                Spacer()
                
                // Action buttons
                VStack(spacing: 12) {
                    Button(action: onDone) {
                        HStack {
                            Image(systemName: "house.fill")
                            Text("Done")
                        }
                        .font(.system(.headline, design: .rounded, weight: .semibold))
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(
                            LinearGradient(
                                colors: [
                                    Color(red: 0.85, green: 0.55, blue: 0.55),
                                    Color(red: 0.75, green: 0.45, blue: 0.50)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .cornerRadius(16)
                        .shadow(color: Color(red: 0.80, green: 0.50, blue: 0.50).opacity(0.35), radius: 8, x: 0, y: 4)
                    }
                    
                    Button(action: onScanAnother) {
                        HStack {
                            Image(systemName: "plus.circle")
                            Text("Scan Another Card")
                        }
                        .font(.system(.subheadline, design: .rounded, weight: .semibold))
                        .foregroundColor(Color(red: 0.85, green: 0.55, blue: 0.55))
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .fill(Color.white)
                                .shadow(color: Color.black.opacity(0.06), radius: 8, x: 0, y: 4)
                        )
                    }
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 32)
                .offset(y: buttonsOffset)
                .opacity(buttonsOpacity)
            }
        }
        .onAppear {
            // Staggered animations
            withAnimation(.spring(response: 0.6, dampingFraction: 0.7)) {
                cardScale = 1.0
                cardOpacity = 1.0
            }
            
            withAnimation(.easeOut(duration: 0.5).delay(0.2)) {
                textOpacity = 1.0
            }
            
            withAnimation(.spring(response: 0.5, dampingFraction: 0.8).delay(0.3)) {
                buttonsOffset = 0
                buttonsOpacity = 1.0
            }
            
            // Trigger confetti
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                showConfetti = true
            }
        }
    }
}

// MARK: - Confetti View
struct ConfettiView: View {
    @State private var confettiPieces: [ConfettiPiece] = []
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                ForEach(confettiPieces) { piece in
                    ConfettiPieceView(piece: piece, screenHeight: geometry.size.height)
                }
            }
            .onAppear {
                createConfetti(in: geometry.size)
            }
        }
    }
    
    private func createConfetti(in size: CGSize) {
        let colors: [Color] = [
            Color(red: 0.85, green: 0.55, blue: 0.55),
            Color(red: 0.95, green: 0.75, blue: 0.45),
            Color(red: 0.40, green: 0.75, blue: 0.45),
            Color(red: 0.55, green: 0.65, blue: 0.85),
            Color(red: 0.80, green: 0.55, blue: 0.75),
            Color(red: 0.95, green: 0.60, blue: 0.60)
        ]
        
        confettiPieces = (0..<50).map { _ in
            ConfettiPiece(
                x: CGFloat.random(in: 0...size.width),
                delay: Double.random(in: 0...0.5),
                color: colors.randomElement()!,
                rotation: Double.random(in: 0...360),
                scale: CGFloat.random(in: 0.5...1.0)
            )
        }
    }
}

// MARK: - Confetti Piece Model
struct ConfettiPiece: Identifiable {
    let id = UUID()
    let x: CGFloat
    let delay: Double
    let color: Color
    let rotation: Double
    let scale: CGFloat
}

// MARK: - Confetti Piece View
struct ConfettiPieceView: View {
    let piece: ConfettiPiece
    let screenHeight: CGFloat
    
    @State private var yOffset: CGFloat = -50
    @State private var opacity: Double = 1
    @State private var currentRotation: Double = 0
    
    var body: some View {
        RoundedRectangle(cornerRadius: 2)
            .fill(piece.color)
            .frame(width: 8 * piece.scale, height: 12 * piece.scale)
            .rotationEffect(.degrees(currentRotation))
            .position(x: piece.x, y: yOffset)
            .opacity(opacity)
            .onAppear {
                currentRotation = piece.rotation
                withAnimation(
                    .easeIn(duration: 2.5)
                    .delay(piece.delay)
                ) {
                    yOffset = screenHeight + 50
                    currentRotation += 720
                }
                withAnimation(
                    .easeIn(duration: 1.0)
                    .delay(piece.delay + 1.5)
                ) {
                    opacity = 0
                }
            }
    }
}

#Preview {
    CelebrationView(
        card: Card(),
        onAddDetails: {},
        onScanAnother: {},
        onDone: {}
    )
}

