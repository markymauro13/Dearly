//
//  CardView.swift
//  Dearly
//
//  Created by Mark Mauro on 10/28/25.
//

import SwiftUI

struct CardView: View {
    @State private var isFlipped = false

    var body: some View {
        ZStack {
            CardSide(color: .blue, text: "Front")
                .opacity(isFlipped ? 0 : 1)
                .rotation3DEffect(
                    .degrees(isFlipped ? 180 : 0),
                    axis: (x: 0.0, y: 1.0, z: 0.0)
                )

            CardSide(color: .red, text: "Back")
                .opacity(isFlipped ? 1 : 0)
                .rotation3DEffect(
                    .degrees(isFlipped ? 0 : -180),
                    axis: (x: 0.0, y: 1.0, z: 0.0)
                )
        }
        .accessibilityIdentifier("CardView")
        .onTapGesture {
            withAnimation(.spring) {
                isFlipped.toggle()
            }
        }
    }
}

struct CardSide: View {
    let color: Color
    let text: String

    var body: some View {
        RoundedRectangle(cornerRadius: 25.0)
            .fill(color)
            .frame(width: 200, height: 300)
            .overlay(
                Text(text)
                    .font(.largeTitle)
                    .foregroundColor(.white)
            )
    }
}

#Preview {
    CardView()
}
