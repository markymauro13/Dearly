//
//  AnimatedCardView.swift
//  Dearly
//
//  Created by Mark Mauro on 10/28/25.
//

import SwiftUI

struct AnimatedCardView: View {
    let card: Card
    @Binding var resetTrigger: Bool
    
    @State private var isOpen = false
    @State private var xOffset: CGFloat = 0
    
    // 3D rotation state
    @State private var rotationX: Double = 0
    @State private var rotationY: Double = 0
    @State private var currentRotationX: Double = 0
    @State private var currentRotationY: Double = 0

    private let cardWidth: CGFloat = 320
    private let cardHeight: CGFloat = 224
    private var pageWidth: CGFloat { cardWidth / 2 }
    private var normalizedRotationY: Double {
        var angle = (currentRotationY + rotationY).truncatingRemainder(dividingBy: 360)
        if angle > 180 { angle -= 360 }
        if angle < -180 { angle += 360 }
        return angle
    }
    private var isFacingFront: Bool { abs(normalizedRotationY) <= 90 }
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // MARK: - Back page (right side)
                ZStack {
                    // BACK COVER (outside when closed)
                    Group {
                        if let backImage = card.backImage {
                            Image(uiImage: backImage)
                                .resizable()
                                .scaledToFill()
                                .frame(width: pageWidth, height: cardHeight)
                                .clipped()
                        } else {
                            Rectangle()
                                .fill(Color.gray.opacity(0.3))
                                .frame(width: pageWidth, height: cardHeight)
                                .overlay(Text("Back").foregroundColor(.white))
                        }
                    }
                    // rotated so it’s only visible from behind
                    .rotation3DEffect(.degrees(180), axis: (x: 0, y: 1, z: 0))
                    .opacity(isOpen ? (isFacingFront ? 0 : 1) : 1) // show when viewing back of open card
                    
                    // INSIDE RIGHT (visible when open)
                    Group {
                        if let rightImage = card.insideRightImage {
                            Image(uiImage: rightImage)
                                .resizable()
                                .scaledToFill()
                                .frame(width: pageWidth, height: cardHeight)
                                .clipped()
                        } else {
                            Rectangle()
                                .fill(Color.white)
                                .frame(width: pageWidth, height: cardHeight)
                                .overlay(Text("Inside Right").foregroundColor(.black))
                        }
                    }
                    .opacity(isOpen ? (isFacingFront ? 1 : 0) : 0)
                }
                .cornerRadius(16)
                .zIndex(0)

                // MARK: - Front page (left side)
                ZStack {
                    // FRONT COVER (outside when closed)
                    Group {
                        if let frontImage = card.frontImage {
                            Image(uiImage: frontImage)
                                .resizable()
                                .scaledToFill()
                                .frame(width: pageWidth, height: cardHeight)
                                .clipped()
                        } else {
                            Rectangle()
                                .fill(Color.white)
                                .frame(width: pageWidth, height: cardHeight)
                                .overlay(Text("Tap to Open").foregroundColor(.black))
                        }
                    }
                    .opacity((isOpen && isFacingFront) ? 0 : 1)
                    
                    // INSIDE LEFT (visible when open)
                    Group {
                        if let leftImage = card.insideLeftImage {
                            Image(uiImage: leftImage)
                                .resizable()
                                .scaledToFill()
                                .frame(width: pageWidth, height: cardHeight)
                                .clipped()
                        } else {
                            Rectangle()
                                .fill(Color.white)
                                .frame(width: pageWidth, height: cardHeight)
                                .overlay(Text("Inside Left").foregroundColor(.black))
                        }
                    }
                    .rotation3DEffect(.degrees(180), axis: (x: 0, y: 1, z: 0))
                    .opacity((isOpen && isFacingFront) ? 1 : 0)
                }
                .cornerRadius(16)
                .shadow(
                    color: Color.black.opacity(isOpen ? 0 : 0.5),
                    radius: isOpen ? 0 : 15,
                    x: 0,
                    y: isOpen ? 0 : 8
                )
                // same open/close animation you had before
                .rotation3DEffect(
                    .degrees(isOpen ? -180 : 0),
                    axis: (x: 0, y: 1, z: 0),
                    anchor: .leading,
                    anchorZ: 0,
                    perspective: 0.4
                )
                .zIndex(1)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .offset(x: xOffset)
            // Apply 3D rotation to entire card
            .rotation3DEffect(
                .degrees(currentRotationX + rotationX),
                axis: (x: 1, y: 0, z: 0)
            )
            .rotation3DEffect(
                .degrees(currentRotationY + rotationY),
                axis: (x: 0, y: 1, z: 0)
            )
        }
        .frame(width: cardWidth, height: cardHeight)
        .gesture(
            // Drag gesture for 3D rotation
            DragGesture()
                .onChanged { value in
                    rotationY = Double(value.translation.width) * 0.5
                    rotationX = Double(-value.translation.height) * 0.5
                }
                .onEnded { _ in
                    currentRotationX += rotationX
                    currentRotationY += rotationY
                    rotationX = 0
                    rotationY = 0
                }
        )
        .simultaneousGesture(
            // Tap gesture for opening/closing card
            TapGesture()
                .onEnded {
                    let impact = UIImpactFeedbackGenerator(style: .medium)
                    impact.impactOccurred()
                    
                    withAnimation(
                        .interpolatingSpring(
                            mass: 1.0,
                            stiffness: 100,
                            damping: 15,
                            initialVelocity: 0
                        )
                    ) {
                        isOpen.toggle()
                        xOffset = isOpen ? pageWidth / 2 : 0
                    }
                }
        )
        .onChange(of: resetTrigger) { _ in
            resetCard()
        }
    }
    
    private func resetCard() {
        withAnimation(.spring(response: 0.6, dampingFraction: 0.7)) {
            isOpen = false
            xOffset = 0
            rotationX = 0
            rotationY = 0
            currentRotationX = 0
            currentRotationY = 0
        }
    }
}

#Preview {
    ZStack {
        Color.black.ignoresSafeArea()
        AnimatedCardView(card: Card(
            frontImageData: nil,
            backImageData: nil,
            insideLeftImageData: nil,
            insideRightImageData: nil
        ), resetTrigger: .constant(false))
        .padding()
    }
}
