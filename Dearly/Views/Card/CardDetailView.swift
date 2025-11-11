//
//  CardDetailView.swift
//  Dearly
//
//  Created by Mark Mauro on 10/28/25.
//

import SwiftUI

struct CardDetailView: View {
    @State var card: Card
    var onUpdate: ((Card) -> Void)?
    @Environment(\.dismiss) private var dismiss
    @State private var resetTrigger = false
    @State private var showingMetadataEdit = false
    @State private var showingShareSheet = false
    
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            VStack {
                // Top buttons
                HStack {
                    Button(action: {
                        // Haptic feedback
                        let impact = UIImpactFeedbackGenerator(style: .medium)
                        impact.impactOccurred()
                        
                        resetTrigger.toggle()
                    }) {
                        Image(systemName: "arrow.counterclockwise.circle.fill")
                            .font(.system(size: 30))
                            .foregroundColor(.white.opacity(0.8))
                    }
                    .padding()
                    
                    Spacer()
                    
                    Button(action: {
                        // Haptic feedback
                        let impact = UIImpactFeedbackGenerator(style: .medium)
                        impact.impactOccurred()
                        
                        showingShareSheet = true
                    }) {
                        Image(systemName: "square.and.arrow.up.circle.fill")
                            .font(.system(size: 30))
                            .foregroundColor(.white.opacity(0.8))
                    }
                    .padding()
                    
                    Button(action: {
                        // Haptic feedback
                        let impact = UIImpactFeedbackGenerator(style: .medium)
                        impact.impactOccurred()
                        
                        showingMetadataEdit = true
                    }) {
                        Image(systemName: "info.circle.fill")
                            .font(.system(size: 30))
                            .foregroundColor(.white.opacity(0.8))
                    }
                    .padding()
                    
                    Button(action: {
                        // Haptic feedback
                        let impact = UIImpactFeedbackGenerator(style: .medium)
                        impact.impactOccurred()
                        
                        dismiss()
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 30))
                            .foregroundColor(.white.opacity(0.8))
                    }
                    .padding()
                }
                
                Spacer()
                
                // Animated Card
                AnimatedCardView(card: card, resetTrigger: $resetTrigger)
                    .padding(.horizontal, 20)
                
                Spacer()
                
                // Metadata display
                if card.sender != nil || card.occasion != nil || card.dateReceived != nil || card.notes != nil {
                    VStack(spacing: 8) {
                        if let sender = card.sender {
                            HStack {
                                Image(systemName: "person.fill")
                                    .foregroundColor(.white.opacity(0.6))
                                Text("From: \(sender)")
                                    .font(.system(size: 14))
                                    .foregroundColor(.white.opacity(0.8))
                            }
                        }
                        
                        if let occasion = card.occasion {
                            HStack {
                                Image(systemName: "calendar")
                                    .foregroundColor(.white.opacity(0.6))
                                Text(occasion)
                                    .font(.system(size: 14))
                                    .foregroundColor(.white.opacity(0.8))
                            }
                        }
                        
                        if let dateReceived = card.dateReceived {
                            HStack {
                                Image(systemName: "clock")
                                    .foregroundColor(.white.opacity(0.6))
                                Text(dateReceived.formatted(date: .abbreviated, time: .omitted))
                                    .font(.system(size: 14))
                                    .foregroundColor(.white.opacity(0.8))
                            }
                        }
                        
                        if let notes = card.notes, !notes.isEmpty {
                            Text(notes)
                                .font(.system(size: 14))
                                .foregroundColor(.white.opacity(0.8))
                                .multilineTextAlignment(.center)
                                .padding(.horizontal)
                        }
                    }
                    .padding(.bottom, 20)
                }
                
                // Instruction text
                Text("Tap to open • Drag to rotate")
                    .font(.system(size: 16))
                    .foregroundColor(.white.opacity(0.6))
                    .padding(.bottom, 40)
            }
        }
        .sheet(isPresented: $showingMetadataEdit) {
            CardMetadataView(card: $card)
                .onDisappear {
                    onUpdate?(card)
                }
        }
        .sheet(isPresented: $showingShareSheet) {
            ShareSheet(items: shareItems())
        }
    }
    
    private func shareItems() -> [Any] {
        var items: [Any] = []
        
        // Add card images
        if let frontImage = card.frontImage {
            items.append(frontImage)
        }
        if let backImage = card.backImage {
            items.append(backImage)
        }
        if let insideLeftImage = card.insideLeftImage {
            items.append(insideLeftImage)
        }
        if let insideRightImage = card.insideRightImage {
            items.append(insideRightImage)
        }
        
        // Add text with metadata
        var text = "Shared from Dearly"
        if let sender = card.sender {
            text += "\nFrom: \(sender)"
        }
        if let occasion = card.occasion {
            text += "\n\(occasion)"
        }
        if let notes = card.notes {
            text += "\n\n\(notes)"
        }
        items.append(text)
        
        return items
    }
}

#Preview {
    CardDetailView(card: Card(
        frontImageData: nil,
        backImageData: nil,
        insideLeftImageData: nil,
        insideRightImageData: nil
    ))
}

