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
    
    // Zoom and pan state
    @State private var scale: CGFloat = 1.0
    @State private var lastScale: CGFloat = 1.0
    @State private var panOffset: CGSize = .zero
    @State private var lastPanOffset: CGSize = .zero
    @State private var pinchLocation: CGPoint = .zero
    @State private var isPinching: Bool = false

    private let cardWidth: CGFloat = 320
    private let cardHeight: CGFloat = 224
    private var pageWidth: CGFloat { cardWidth / 2 }
    private let edgeThickness: CGFloat = 4
    private var normalizedRotationY: Double {
        var angle = (currentRotationY + rotationY).truncatingRemainder(dividingBy: 360)
        if angle > 180 { angle -= 360 }
        if angle < -180 { angle += 360 }
        return angle
    }
    private var isFacingFront: Bool { abs(normalizedRotationY) <= 90 }
    private func edgeGradient(forLeadingEdge leading: Bool) -> LinearGradient {
        let shadow = Color.black.opacity(0.55)
        let highlight = Color.white.opacity(0.5)
        return LinearGradient(
            colors: leading ? [shadow, highlight] : [highlight, shadow],
            startPoint: .leading,
            endPoint: .trailing
        )
    }
    
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
                    .overlay(alignment: .leading) {
                        thicknessEdge(isLeading: true, opacity: isOpen ? 0.7 : 0.45)
                    }
                    .overlay(alignment: .trailing) {
                        thicknessEdge(isLeading: false, opacity: isOpen ? 0.25 : 0.15)
                    }
                    // rotated so it's only visible from behind
                    .rotation3DEffect(.degrees(180), axis: (x: 0, y: 1, z: 0))
                    .opacity(isOpen ? 0 : 1)
                    .animation(isOpen ? nil : .interpolatingSpring(mass: 1.0, stiffness: 100, damping: 15, initialVelocity: 0), value: isOpen) // Instant hide when opening, smooth fade when closing
                    
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
                    .overlay(alignment: .leading) {
                        thicknessEdge(isLeading: true, opacity: isOpen ? 0.4 : 0.1)
                    }
                    .overlay(alignment: .trailing) {
                        thicknessEdge(isLeading: false, opacity: isOpen ? 0.25 : 0.1)
                    }
                    .opacity(isOpen ? 1 : 0)
                    .animation(isOpen ? nil : .interpolatingSpring(mass: 1.0, stiffness: 100, damping: 15, initialVelocity: 0), value: isOpen) // Instant show when opening, smooth fade when closing
                    .rotation3DEffect(
                        .degrees(isOpen ? 0 : 90),
                        axis: (x: 0, y: 1, z: 0),
                        anchor: .leading,
                        anchorZ: 0,
                        perspective: 0.4
                    )
                }
                .cornerRadius(20)
                .zIndex(isFacingFront ? 0 : 1)

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
                    .overlay(alignment: .leading) {
                        thicknessEdge(isLeading: true, opacity: isOpen ? 0.3 : 0.5)
                    }
                    .overlay(alignment: .trailing) {
                        thicknessEdge(isLeading: false, opacity: isFacingFront ? 0.8 : 0.35)
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
                    .overlay(alignment: .leading) {
                        thicknessEdge(isLeading: true, opacity: isOpen ? 0.35 : 0.15)
                    }
                    .overlay(alignment: .trailing) {
                        thicknessEdge(isLeading: false, opacity: isOpen ? 0.5 : 0.25)
                    }
                    .rotation3DEffect(.degrees(180), axis: (x: 0, y: 1, z: 0))
                    .opacity((isOpen && isFacingFront) ? 1 : 0)
                }
                .cornerRadius(20)
                .shadow(
                    color: Color.black.opacity(isOpen ? 0 : 0.12),
                    radius: isOpen ? 0 : 20,
                    x: 0,
                    y: isOpen ? 0 : 10
                )
                .shadow(
                    color: Color.black.opacity(isOpen ? 0 : 0.08),
                    radius: isOpen ? 0 : 8,
                    x: 0,
                    y: isOpen ? 0 : 4
                )
                // same open/close animation you had before
                .rotation3DEffect(
                    .degrees(isOpen ? -180 : 0),
                    axis: (x: 0, y: 1, z: 0),
                    anchor: .leading,
                    anchorZ: 0,
                    perspective: 0.4
                )
                .zIndex(isFacingFront ? 1 : 0)
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
        // Apply zoom and pan - OUTSIDE the frame so it can expand
        .scaleEffect(scale)
        .offset(x: panOffset.width, y: panOffset.height)
        .gesture(
            // Drag gesture - pan when zoomed OR during pinch, otherwise rotate
            DragGesture()
                .onChanged { value in
                    if scale > 1.0 || isPinching {
                        // Pan when zoomed or while pinching
                        panOffset = CGSize(
                            width: lastPanOffset.width + value.translation.width,
                            height: lastPanOffset.height + value.translation.height
                        )
                    } else {
                        // Rotate when not zoomed
                        rotationY = Double(value.translation.width) * 0.5
                        rotationX = Double(-value.translation.height) * 0.5
                    }
                }
                .onEnded { _ in
                    if scale > 1.0 || isPinching {
                        // Save pan position
                        lastPanOffset = panOffset
                    } else {
                        // Save rotation position
                        currentRotationX += rotationX
                        currentRotationY += rotationY
                        rotationX = 0
                        rotationY = 0
                    }
                }
        )
        .gesture(
            // Pinch to zoom with focal point
            MagnificationGesture()
                .onChanged { value in
                    isPinching = true
                    
                    let delta = value / lastScale
                    lastScale = value
                    
                    let oldScale = scale
                    let newScale = min(max(scale * delta, 1.0), 5.0) // Limit zoom between 1x and 5x
                    
                    // Calculate focal point adjustment
                    if oldScale != newScale {
                        let scaleDifference = newScale - oldScale
                        
                        // Adjust pan offset to zoom into the pinch location
                        // The pinch location is relative to the card center
                        panOffset.width = lastPanOffset.width - (pinchLocation.x * scaleDifference)
                        panOffset.height = lastPanOffset.height - (pinchLocation.y * scaleDifference)
                        lastPanOffset = panOffset
                    }
                    
                    scale = newScale
                }
                .onEnded { _ in
                    lastScale = 1.0
                    isPinching = false
                    
                    // Reset to 1.0 if close to it
                    if scale < 1.1 {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                            scale = 1.0
                            panOffset = .zero
                            lastPanOffset = .zero
                        }
                    }
                }
        )
        .onTapGesture(count: 2, perform: {
            // Double tap to toggle zoom
            if scale > 1.0 {
                // Zoom out
                let impact = UIImpactFeedbackGenerator(style: .light)
                impact.impactOccurred()
                
                withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                    scale = 1.0
                    panOffset = .zero
                    lastPanOffset = .zero
                }
            }
        })
        .gesture(
            // Track pinch location for focal point zoom
            DragGesture(minimumDistance: 0)
                .onChanged { value in
                    if isPinching {
                        // Update pinch location relative to card center
                        pinchLocation = CGPoint(
                            x: value.location.x - cardWidth / 2,
                            y: value.location.y - cardHeight / 2
                        )
                    }
                }
        )
        .simultaneousGesture(
            // Tap gesture for opening/closing card - works at any zoom
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
    
    @ViewBuilder
    private func thicknessEdge(isLeading: Bool, opacity: Double) -> some View {
        Rectangle()
            .fill(edgeGradient(forLeadingEdge: isLeading))
            .frame(width: edgeThickness)
            .opacity(opacity)
            .blur(radius: 0.25)
    }
    
    private func resetCard() {
        withAnimation(.spring(response: 0.6, dampingFraction: 0.7)) {
            isOpen = false
            xOffset = 0
            rotationX = 0
            rotationY = 0
            currentRotationX = 0
            currentRotationY = 0
            scale = 1.0
            panOffset = .zero
            lastPanOffset = .zero
            lastScale = 1.0
            pinchLocation = .zero
            isPinching = false
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
