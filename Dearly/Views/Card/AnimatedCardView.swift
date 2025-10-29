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
        GeometryReader { geometry in
            ZStack {
                // Inside right page (static, always underneath)
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
                .cornerRadius(16)
                .opacity(isOpen ? 1 : 0)
                .zIndex(0)
                
                // Double-sided page: Front cover / Inside left
                ZStack {
                    // Front side (visible when closed)
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
                    .opacity(isOpen ? 0 : 1)
                    .rotation3DEffect(
                        .degrees(0),
                        axis: (x: 0, y: 1, z: 0)
                    )
                    
                    // Back side (inside left - visible when open)
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
                                .overlay(Text("Inside Left").foregroundColor(Color.black))
                        }
                    }
                    .rotation3DEffect(
                        .degrees(180),
                        axis: (x: 0, y: 1, z: 0)
                    )
                    .opacity(isOpen ? 1 : 0)
                }
                .cornerRadius(16)
                .shadow(
                    color: Color.black.opacity(isOpen ? 0 : 0.5),
                    radius: isOpen ? 0 : 15,
                    x: 0,
                    y: isOpen ? 0 : 8
                )
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
        }
        .frame(width: 320, height: 224)
        .onTapGesture {
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
            }
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
        ))
        .padding()
    }
}

