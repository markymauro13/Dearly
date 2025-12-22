//
//  DeveloperSettingsView.swift
//  Dearly
//
//  Created by Mark Mauro on 11/13/25.
//

import SwiftUI
import SwiftData
import SuperwallKit

struct DeveloperSettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var viewModel: CardsViewModel
    @Binding var hasCompletedOnboarding: Bool
    
    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("Developer Tools")) {
                    Button(action: {
                        testPaywall()
                    }) {
                        HStack {
                            Image(systemName: "creditcard.fill")
                                .foregroundColor(.green)
                            Text("Test Paywall")
                            Spacer()
                        }
                    }
                    
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
                
                Section(header: Text("Performance")) {
                    NavigationLink(destination: PerformanceTestView(viewModel: viewModel)) {
                        HStack {
                            Image(systemName: "speedometer")
                                .foregroundColor(.green)
                            Text("Performance Testing")
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
    
    private func testPaywall() {
        // Register a test placement to trigger a paywall
        Superwall.shared.register(placement: "test_paywall") {
            print("✅ Feature unlocked! User has access.")
        }
    }
    
    private func resetOnboarding() {
        hasCompletedOnboarding = false
        dismiss()
    }
    
    private func addDummyCard() {
        let sender = "Test Sender \(Int.random(in: 1...100))"
        let occasion = ["Birthday", "Holiday", "Anniversary", "Thank You"].randomElement() ?? "Birthday"
        
        // Premium muted color palette
        let colors: [UIColor] = [
            UIColor(red: 0.75, green: 0.65, blue: 1.0, alpha: 1.0),    // Lavender
            UIColor(red: 1.0, green: 0.54, blue: 0.54, alpha: 1.0),    // Coral
            UIColor(red: 0.42, green: 0.67, blue: 1.0, alpha: 1.0),    // Ocean Blue
            UIColor(red: 0.66, green: 0.90, blue: 0.81, alpha: 1.0),   // Mint
            UIColor(red: 1.0, green: 0.76, blue: 0.65, alpha: 1.0),    // Peach
            UIColor(red: 0.85, green: 0.73, blue: 0.95, alpha: 1.0)    // Soft Purple
        ]
        
        let _ = viewModel.addCard(
            frontImage: createPlaceholderImage(text: "FRONT", color: colors.randomElement() ?? .systemBlue),
            backImage: createPlaceholderImage(text: "BACK", color: colors.randomElement() ?? .systemPink),
            insideLeftImage: createPlaceholderImage(text: "INSIDE\nLEFT", color: colors.randomElement() ?? .systemPurple),
            insideRightImage: createPlaceholderImage(text: "INSIDE\nRIGHT", color: colors.randomElement() ?? .systemTeal),
            sender: sender,
            occasion: occasion,
            dateReceived: Date().addingTimeInterval(-Double.random(in: 0...31536000)),
            notes: Bool.random() ? "This is a test note for the dummy card." : nil
        )
        
        // Haptic feedback
        let impact = UIImpactFeedbackGenerator(style: .medium)
        impact.impactOccurred()
    }
    
    private func addMultipleDummyCards() {
        let senders = ["Mom", "Dad", "Grandma", "Best Friend", "Aunt Sarah"]
        let occasions = ["Birthday", "Holiday", "Anniversary", "Thank You", "Get Well"]
        
        // Premium muted color palette
        let colors: [UIColor] = [
            UIColor(red: 0.75, green: 0.65, blue: 1.0, alpha: 1.0),    // Lavender
            UIColor(red: 1.0, green: 0.54, blue: 0.54, alpha: 1.0),    // Coral
            UIColor(red: 0.42, green: 0.67, blue: 1.0, alpha: 1.0),    // Ocean Blue
            UIColor(red: 0.66, green: 0.90, blue: 0.81, alpha: 1.0),   // Mint
            UIColor(red: 1.0, green: 0.76, blue: 0.65, alpha: 1.0),    // Peach
            UIColor(red: 0.85, green: 0.73, blue: 0.95, alpha: 1.0)    // Soft Purple
        ]
        
        // Add cards with a small delay between each to let SwiftData process
        Task {
            for i in 0..<5 {
                let _ = viewModel.addCard(
                    frontImage: createPlaceholderImage(text: "FRONT", color: colors.randomElement() ?? .systemBlue),
                    backImage: createPlaceholderImage(text: "BACK", color: colors.randomElement() ?? .systemPink),
                    insideLeftImage: createPlaceholderImage(text: "INSIDE\nLEFT", color: colors.randomElement() ?? .systemPurple),
                    insideRightImage: createPlaceholderImage(text: "INSIDE\nRIGHT", color: colors.randomElement() ?? .systemTeal),
                    sender: senders[i],
                    occasion: occasions[i],
                    dateReceived: Date().addingTimeInterval(-Double.random(in: 0...31536000)),
                    notes: Bool.random() ? "This is a test note for the dummy card." : nil
                )
                
                // Small delay to let SwiftData process the save
                try? await Task.sleep(nanoseconds: 50_000_000) // 0.05 seconds
            }
            
            // Haptic feedback after all cards are added
            await MainActor.run {
                let impact = UIImpactFeedbackGenerator(style: .medium)
                impact.impactOccurred()
            }
        }
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
        viewModel.clearAllData()
        
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
    .modelContainer(for: Card.self, inMemory: true)
}
