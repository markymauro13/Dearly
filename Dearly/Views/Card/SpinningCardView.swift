//
//  SpinningCardView.swift
//  Dearly
//
//  Created by Mark Mauro on 10/28/25.
//

import SwiftUI

struct SpinningCardView: View {
    let card: Card

    @State private var rotation: Double = 0
    
    private var frontOpacity: Double {
        let normalizedRotation = rotation.truncatingRemainder(dividingBy: 360)
        let absRotation = abs(normalizedRotation)
        if absRotation > 90 && absRotation < 270 {
            return 0
        }
        return 1
    }
    
    private var backOpacity: Double {
        let normalizedRotation = rotation.truncatingRemainder(dividingBy: 360)
        let absRotation = abs(normalizedRotation)
        if absRotation > 90 && absRotation < 270 {
            return 1
        }
        return 0
    }

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Back of the card (4th scan)
                Group {
                    if let backImage = card.backImage {
                        Image(uiImage: backImage)
                            .resizable()
                            .scaledToFill()
                            .frame(width: geometry.size.width, height: geometry.size.width * 1.4)
                            .clipped()
                            .cornerRadius(12)
                    } else {
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color.gray.opacity(0.4))
                            .frame(width: geometry.size.width, height: geometry.size.width * 1.4)
                            .overlay(
                                Image(systemName: "questionmark")
                                    .foregroundColor(.white)
                            )
                    }
                }
                .rotation3DEffect(
                    .degrees(180),
                    axis: (x: 0.0, y: 1.0, z: 0.0)
                )
                .opacity(backOpacity)

                // Front of the card (1st scan)
                Group {
                    if let frontImage = card.frontImage {
                        Image(uiImage: frontImage)
                            .resizable()
                            .scaledToFill()
                            .frame(width: geometry.size.width, height: geometry.size.width * 1.4)
                            .clipped()
                            .cornerRadius(12)
                    } else {
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color.gray.opacity(0.2))
                            .frame(width: geometry.size.width, height: geometry.size.width * 1.4)
                            .overlay(
                                Image(systemName: "photo")
                                    .foregroundColor(.gray)
                            )
                    }
                }
                .opacity(frontOpacity)
            }
            .rotation3DEffect(
                .degrees(rotation),
                axis: (x: 0.0, y: 1.0, z: 0.0)
            )
            .gesture(
                DragGesture()
                    .onChanged { value in
                        rotation += Double(value.translation.width) / 4
                    }
            )
            .shadow(color: .black.opacity(0.2), radius: 4, x: 0, y: 2)
            .onAppear {
                withAnimation(
                    .linear(duration: 8)
                    .repeatForever(autoreverses: false)
                ) {
                    rotation = 360
                }
            }
        }
        .aspectRatio(1/1.4, contentMode: .fit)
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
