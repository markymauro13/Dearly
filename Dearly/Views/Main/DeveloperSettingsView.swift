//
//  DeveloperSettingsView.swift
//  Dearly
//
//  Created by Mark Mauro on 11/13/25.
//

import SwiftUI

struct DeveloperSettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var viewModel: CardsViewModel
    @Binding var hasCompletedOnboarding: Bool
    
    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("Developer Tools")) {
                    Button(action: {
                        resetOnboarding()
                    }) {
                        HStack {
                            Image(systemName: "arrow.counterclockwise.circle.fill")
                                .foregroundColor(.orange)
                            Text("Reset Onboarding")
                            Spacer()
                        }
                    }
                    
                    Button(action: {
                        addDummyCard()
                    }) {
                        HStack {
                            Image(systemName: "plus.circle.fill")
                                .foregroundColor(.blue)
                            Text("Add Dummy Card")
                            Spacer()
                        }
                    }
                    
                    Button(action: {
                        addMultipleDummyCards()
                    }) {
                        HStack {
                            Image(systemName: "square.stack.3d.up.fill")
                                .foregroundColor(.purple)
                            Text("Add 5 Dummy Cards")
                            Spacer()
                        }
                    }
                }
                
                Section(header: Text("Data Management")) {
                    HStack {
                        Text("Total Cards")
                        Spacer()
                        Text("\(viewModel.cards.count)")
                            .foregroundColor(.secondary)
                    }
                    
                    Button(action: {
                        clearAllCards()
                    }) {
                        HStack {
                            Image(systemName: "trash.circle.fill")
                                .foregroundColor(.red)
                            Text("Clear All Cards")
                            Spacer()
                        }
                    }
                }
            }
            .navigationTitle("Developer Settings")
            .navigationBarTitleDisplayMode(.inline)
            .preferredColorScheme(.light)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
    
    private func resetOnboarding() {
        hasCompletedOnboarding = false
        dismiss()
    }
    
    private func addDummyCard() {
        let dummyCard = createDummyCard(
            sender: "Test Sender \(Int.random(in: 1...100))",
            occasion: ["Birthday", "Holiday", "Anniversary", "Thank You"].randomElement() ?? "Birthday"
        )
        viewModel.addCard(dummyCard)
        
        // Haptic feedback
        let impact = UIImpactFeedbackGenerator(style: .medium)
        impact.impactOccurred()
    }
    
    private func addMultipleDummyCards() {
        let senders = ["Mom", "Dad", "Grandma", "Best Friend", "Aunt Sarah"]
        let occasions = ["Birthday", "Holiday", "Anniversary", "Thank You", "Get Well"]
        
        for i in 0..<5 {
            let dummyCard = createDummyCard(
                sender: senders[i],
                occasion: occasions[i]
            )
            viewModel.addCard(dummyCard)
        }
        
        // Haptic feedback
        let impact = UIImpactFeedbackGenerator(style: .medium)
        impact.impactOccurred()
    }
    
    private func createDummyCard(sender: String, occasion: String) -> Card {
        // Premium muted color palette
        let colors: [UIColor] = [
            UIColor(red: 0.75, green: 0.65, blue: 1.0, alpha: 1.0),    // Lavender
            UIColor(red: 1.0, green: 0.54, blue: 0.54, alpha: 1.0),    // Coral
            UIColor(red: 0.42, green: 0.67, blue: 1.0, alpha: 1.0),    // Ocean Blue
            UIColor(red: 0.66, green: 0.90, blue: 0.81, alpha: 1.0),   // Mint
            UIColor(red: 1.0, green: 0.76, blue: 0.65, alpha: 1.0),    // Peach
            UIColor(red: 0.85, green: 0.73, blue: 0.95, alpha: 1.0)    // Soft Purple
        ]
        
        return Card(
            frontImageData: createPlaceholderImage(text: "FRONT", color: colors.randomElement() ?? .systemBlue).jpegData(compressionQuality: 0.8),
            backImageData: createPlaceholderImage(text: "BACK", color: colors.randomElement() ?? .systemPink).jpegData(compressionQuality: 0.8),
            insideLeftImageData: createPlaceholderImage(text: "INSIDE\nLEFT", color: colors.randomElement() ?? .systemPurple).jpegData(compressionQuality: 0.8),
            insideRightImageData: createPlaceholderImage(text: "INSIDE\nRIGHT", color: colors.randomElement() ?? .systemTeal).jpegData(compressionQuality: 0.8),
            dateScanned: Date().addingTimeInterval(-Double.random(in: 0...31536000)), // Random date within last year
            isFavorite: Bool.random(),
            sender: sender,
            occasion: occasion,
            dateReceived: Date().addingTimeInterval(-Double.random(in: 0...31536000)),
            notes: Bool.random() ? "This is a test note for the dummy card." : nil
        )
    }
    
    private func createPlaceholderImage(text: String, color: UIColor) -> UIImage {
        let size = CGSize(width: 600, height: 840) // 1:1.4 aspect ratio for card
        let renderer = UIGraphicsImageRenderer(size: size)
        
        return renderer.image { context in
            // Off-white background
            UIColor(red: 0.98, green: 0.98, blue: 0.96, alpha: 1.0).setFill()
            context.fill(CGRect(origin: .zero, size: size))
            
            // Draw colored border frame (6-8pt as suggested)
            color.setStroke()
            let borderInset: CGFloat = 20
            let borderRect = CGRect(
                x: borderInset,
                y: borderInset,
                width: size.width - (borderInset * 2),
                height: size.height - (borderInset * 2)
            )
            let borderPath = UIBezierPath(roundedRect: borderRect, cornerRadius: 24)
            borderPath.lineWidth = 8
            borderPath.stroke()
            
            // Add decorative corner elements
            let cornerSize: CGFloat = 40
            let cornerPath = UIBezierPath()
            
            // Top-left corner
            cornerPath.move(to: CGPoint(x: borderInset + 30, y: borderInset + 30))
            cornerPath.addLine(to: CGPoint(x: borderInset + 30 + cornerSize, y: borderInset + 30))
            cornerPath.move(to: CGPoint(x: borderInset + 30, y: borderInset + 30))
            cornerPath.addLine(to: CGPoint(x: borderInset + 30, y: borderInset + 30 + cornerSize))
            
            color.setStroke()
            cornerPath.lineWidth = 3
            cornerPath.stroke()
            
            // Add text
            let paragraphStyle = NSMutableParagraphStyle()
            paragraphStyle.alignment = .center
            
            let attributes: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: 56, weight: .semibold),
                .foregroundColor: color.withAlphaComponent(0.7),
                .paragraphStyle: paragraphStyle,
                .kern: 2.0 // Letter spacing
            ]
            
            let textRect = CGRect(x: 0, y: (size.height - 70) / 2, width: size.width, height: 70)
            text.draw(in: textRect, withAttributes: attributes)
        }
    }
    
    private func clearAllCards() {
        viewModel.cards.removeAll()
        viewModel.cards = []
        
        // Manually trigger save
        // (Since we're directly modifying, we need to call the repository)
        let repository = CardRepository()
        repository.saveCards([])
        
        // Haptic feedback
        let impact = UIImpactFeedbackGenerator(style: .heavy)
        impact.impactOccurred()
    }
}

#Preview {
    DeveloperSettingsView(
        viewModel: CardsViewModel(),
        hasCompletedOnboarding: .constant(true)
    )
}

