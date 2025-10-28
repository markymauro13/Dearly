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
    
    // Split inside spread into left and right halves
    private var insideLeftImage: UIImage? {
        guard let spread = card.insideSpreadImage else { return nil }
        return splitImageLeft(spread)
    }
    
    private var insideRightImage: UIImage? {
        guard let spread = card.insideSpreadImage else { return nil }
        return splitImageRight(spread)
    }
    
    var body: some View {
        ZStack {
            // Inside pages (static, always underneath)
            HStack(spacing: 0) {
                // Left inside page
                Group {
                    if let leftImage = insideLeftImage {
                        Image(uiImage: leftImage)
                            .resizable()
                            .scaledToFill()
                            .frame(width: 160, height: 224)
                            .clipped()
                    } else {
                        Rectangle()
                            .fill(Color.white)
                            .frame(width: 160, height: 224)
                            .overlay(Text("Left").foregroundColor(Color.black))
                    }
                }
                
                // Right inside page
                Group {
                    if let rightImage = insideRightImage {
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
            }
            .cornerRadius(16)
            .shadow(color: Color.black.opacity(0.3), radius: 10, x: 0, y: 5)
            
            // Front cover (rotates to reveal inside)
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
            .cornerRadius(16)
            .shadow(color: Color.black.opacity(0.5), radius: 15, x: 0, y: 8)
            .rotation3DEffect(
                .degrees(isOpen ? -160 : 0),
                axis: (x: 0, y: 1, z: 0),
                anchor: .leading,
                perspective: 0.3
            )
            .opacity(isOpen ? 0 : 1)
        }
        .onTapGesture {
            let impact = UIImpactFeedbackGenerator(style: .medium)
            impact.impactOccurred()
            
            withAnimation(.spring(response: 0.8, dampingFraction: 0.7)) {
                isOpen.toggle()
            }
        }
    }
    
    // MARK: - Image Splitting
    
    private func splitImageLeft(_ image: UIImage) -> UIImage? {
        // Fix orientation first by rendering to a new context
        UIGraphicsBeginImageContextWithOptions(image.size, false, image.scale)
        image.draw(in: CGRect(origin: .zero, size: image.size))
        guard let normalizedImage = UIGraphicsGetImageFromCurrentImageContext() else {
            UIGraphicsEndImageContext()
            return nil
        }
        UIGraphicsEndImageContext()
        
        let width = normalizedImage.size.width
        let height = normalizedImage.size.height
        let leftRect = CGRect(x: 0, y: 0, width: width / 2, height: height)
        
        guard let cgImage = normalizedImage.cgImage,
              let leftCgImage = cgImage.cropping(to: leftRect) else {
            return nil
        }
        
        return UIImage(cgImage: leftCgImage, scale: normalizedImage.scale, orientation: .up)
    }
    
    private func splitImageRight(_ image: UIImage) -> UIImage? {
        // Fix orientation first by rendering to a new context
        UIGraphicsBeginImageContextWithOptions(image.size, false, image.scale)
        image.draw(in: CGRect(origin: .zero, size: image.size))
        guard let normalizedImage = UIGraphicsGetImageFromCurrentImageContext() else {
            UIGraphicsEndImageContext()
            return nil
        }
        UIGraphicsEndImageContext()
        
        let width = normalizedImage.size.width
        let height = normalizedImage.size.height
        let rightRect = CGRect(x: width / 2, y: 0, width: width / 2, height: height)
        
        guard let cgImage = normalizedImage.cgImage,
              let rightCgImage = cgImage.cropping(to: rightRect) else {
            return nil
        }
        
        return UIImage(cgImage: rightCgImage, scale: normalizedImage.scale, orientation: .up)
    }
    
}

#Preview {
    ZStack {
        Color.black.ignoresSafeArea()
        AnimatedCardView(card: Card(
            frontImageData: nil,
            insideSpreadImageData: nil
        ))
        .padding()
    }
}

