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

    private var isFlipped: Bool {
        let angle = rotation.truncatingRemainder(dividingBy: 360)
        return angle < -90 || angle > 90
    }

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Front of the card
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
                .opacity(isFlipped ? 0 : 1)

                // Back of the card (placeholder)
                Group {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.gray.opacity(0.4))
                        .frame(width: geometry.size.width, height: geometry.size.width * 1.4)
                        .overlay(
                            Image(systemName: "questionmark")
                                .foregroundColor(.white)
                        )
                        .rotation3DEffect(
                            .degrees(180),
                            axis: (x: 0.0, y: 1.0, z: 0.0)
                        )
                }
                .opacity(isFlipped ? 1 : 0)
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
