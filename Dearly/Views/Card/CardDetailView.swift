//
//  CardDetailView.swift
//  Dearly
//
//  Created by Mark Mauro on 10/28/25.
//

import SwiftUI
import SwiftData

enum CardPage: String, CaseIterable {
    case front = "Front"
    case back = "Back"
    case insideLeft = "Outside"
    case insideRight = "Inside"
}

struct CardDetailView: View {
    let cardId: UUID
    @ObservedObject var viewModel: CardsViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var resetTrigger = false
    @State private var showingMetadataEdit = false
    @State private var showingShareSheet = false
    @State private var particleOffset: CGFloat = 0
    @State private var heartScale: CGFloat = 1.0
    @State private var selectedPage: CardPage = .front
    
    private var card: Card? {
        viewModel.cards.first { $0.id == cardId }
    }
    
    var body: some View {
        ZStack {
            // Ethereal gradient background
            LinearGradient(
                gradient: Gradient(colors: [
                    Color(red: 0.05, green: 0.05, blue: 0.15),  // Deep midnight blue
                    Color(red: 0.08, green: 0.05, blue: 0.12),  // Dark purple
                    Color.black
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            // Subtle floating particles for whimsy
            FloatingParticles()
                .opacity(0.3)
            
            VStack(spacing: 0) {
                // Premium frosted glass buttons
                HStack {
                    // Left group - Secondary actions
                    HStack(spacing: 12) {
                        GlassButton(icon: "arrow.counterclockwise", color: .white) {
                            let impact = UIImpactFeedbackGenerator(style: .medium)
                            impact.impactOccurred()
                            resetTrigger.toggle()
                        }
                        
                        GlassButton(
                            icon: card?.isFavorite == true ? "heart.fill" : "heart",
                            color: card?.isFavorite == true ? Color(red: 1.0, green: 0.54, blue: 0.54) : .white
                        ) {
                            let impact = UIImpactFeedbackGenerator(style: .light)
                            impact.impactOccurred()
                            
                            guard let card = card else { return }
                            viewModel.toggleFavorite(for: card)
                            
                            // Heart burst animation
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.5)) {
                                heartScale = 1.3
                            }
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.7).delay(0.1)) {
                                heartScale = 1.0
                            }
                        }
                    }
                    .padding(.leading, 20)
                    
                    Spacer()
                    
                    // Right group - Primary actions
                    HStack(spacing: 12) {
                        GlassButton(icon: "square.and.arrow.up", color: .white) {
                            let impact = UIImpactFeedbackGenerator(style: .medium)
                            impact.impactOccurred()
                            showingShareSheet = true
                        }
                        
                        GlassButton(icon: "info.circle", color: .white) {
                            let impact = UIImpactFeedbackGenerator(style: .medium)
                            impact.impactOccurred()
                            showingMetadataEdit = true
                        }
                        
                        GlassButton(icon: "xmark", color: .white) {
                            let impact = UIImpactFeedbackGenerator(style: .medium)
                            impact.impactOccurred()
                            dismiss()
                        }
                    }
                    .padding(.trailing, 20)
                }
                .padding(.top, 16)
                
                Spacer()
                
                // Card with soft spotlight effect
                ZStack {
                    // Soft radial glow behind card
                    Circle()
                        .fill(
                            RadialGradient(
                                gradient: Gradient(colors: [
                                    Color.white.opacity(0.08),
                                    Color.clear
                                ]),
                                center: .center,
                                startRadius: 50,
                                endRadius: 200
                            )
                        )
                        .frame(width: 400, height: 400)
                        .blur(radius: 30)
                    
                    // Animated Card
                    if let card = card {
                        AnimatedCardView(card: card, resetTrigger: $resetTrigger, selectedPage: $selectedPage)
                            .padding(.horizontal, 20)
                            .scaleEffect(heartScale)
                    }
                }
                
                // Compact segmented control for page selection
                Picker("", selection: $selectedPage) {
                    ForEach(CardPage.allCases, id: \.self) { page in
                        Text(page.rawValue).tag(page)
                    }
                }
                .pickerStyle(.segmented)
                .padding(.horizontal, 40)
                .padding(.top, 20)
                .onChange(of: selectedPage) { _ in
                    let impact = UIImpactFeedbackGenerator(style: .light)
                    impact.impactOccurred()
                }
                
                Spacer()
                
                // Unified metadata card
                if let card = card, card.sender != nil || card.occasion != nil || card.dateReceived != nil || card.notes != nil {
                    VStack(alignment: .leading, spacing: 12) {
                        // Sender row
                        if let sender = card.sender {
                            HStack(spacing: 12) {
                                Image(systemName: "person.fill")
                                    .font(.system(size: 14, weight: .semibold))
                                    .foregroundColor(Color(red: 0.75, green: 0.65, blue: 1.0))
                                    .frame(width: 24)
                                
                                Text(sender)
                                    .font(.system(size: 15, weight: .medium, design: .rounded))
                                    .foregroundColor(.white.opacity(0.95))
                                
                                Spacer()
                            }
                        }
                        
                        // Occasion row
                        if let occasion = card.occasion {
                            HStack(spacing: 12) {
                                Image(systemName: "gift.fill")
                                    .font(.system(size: 14, weight: .semibold))
                                    .foregroundColor(Color(red: 1.0, green: 0.54, blue: 0.54))
                                    .frame(width: 24)
                                
                                Text(occasion)
                                    .font(.system(size: 15, weight: .medium, design: .rounded))
                                    .foregroundColor(.white.opacity(0.95))
                                
                                Spacer()
                            }
                        }
                        
                        // Date row
                        if let dateReceived = card.dateReceived {
                            HStack(spacing: 12) {
                                Image(systemName: "calendar")
                                    .font(.system(size: 14, weight: .semibold))
                                    .foregroundColor(Color(red: 0.42, green: 0.67, blue: 1.0))
                                    .frame(width: 24)
                                
                                Text(dateReceived.formatted(date: .abbreviated, time: .omitted))
                                    .font(.system(size: 15, weight: .medium, design: .rounded))
                                    .foregroundColor(.white.opacity(0.95))
                                
                                Spacer()
                            }
                        }
                        
                        // Notes row (if present)
                        if let notes = card.notes, !notes.isEmpty {
                            VStack(alignment: .leading, spacing: 8) {
                                HStack(spacing: 12) {
                                    Image(systemName: "note.text")
                                        .font(.system(size: 14, weight: .semibold))
                                        .foregroundColor(Color(red: 0.6, green: 0.8, blue: 0.6))
                                        .frame(width: 24)
                                    
                                    Text("Notes")
                                        .font(.system(size: 13, weight: .semibold, design: .rounded))
                                        .foregroundColor(.white.opacity(0.7))
                                    
                                    Spacer()
                                }
                                
                                Text(notes)
                                    .font(.system(size: 14, design: .rounded))
                                    .foregroundColor(.white.opacity(0.85))
                                    .lineLimit(3)
                                    .padding(.leading, 36)
                            }
                        }
                    }
                    .padding(20)
                    .background(
                        RoundedRectangle(cornerRadius: 20)
                            .fill(.ultraThinMaterial.opacity(0.5))
                            .overlay(
                                RoundedRectangle(cornerRadius: 20)
                                    .strokeBorder(Color.white.opacity(0.15), lineWidth: 1)
                            )
                    )
                    .shadow(color: .black.opacity(0.2), radius: 12, x: 0, y: 6)
                    .padding(.horizontal, 24)
                    .padding(.bottom, 16)
                }
                
                // Subtle instruction text
                Text("Drag to rotate • Pinch to zoom • Tap to open")
                    .font(.system(size: 11, design: .rounded))
                    .foregroundColor(.white.opacity(0.35))
                    .padding(.bottom, 40)
            }
        }
        .preferredColorScheme(.dark)
        .sheet(isPresented: $showingMetadataEdit) {
            if let index = viewModel.cards.firstIndex(where: { $0.id == cardId }) {
                CardMetadataView(card: $viewModel.cards[index])
            }
        }
        .sheet(isPresented: $showingShareSheet) {
            if let card = card {
                ShareSheet(items: shareItems(for: card))
            }
        }
    }
    
    private func shareItems(for card: Card) -> [Any] {
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

// MARK: - Glass Button Component
struct GlassButton: View {
    let icon: String
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Image(systemName: icon)
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(color)
                .frame(width: 44, height: 44)
                .background(
                    ZStack {
                        // Frosted glass effect
                        RoundedRectangle(cornerRadius: 14)
                            .fill(.ultraThinMaterial.opacity(0.5))
                        
                        // Subtle border
                        RoundedRectangle(cornerRadius: 14)
                            .strokeBorder(Color.white.opacity(0.2), lineWidth: 1)
                    }
                )
                .shadow(color: color.opacity(0.2), radius: 8, x: 0, y: 4)
        }
    }
}

// MARK: - Metadata Chip Component
struct MetadataChip: View {
    let icon: String
    let text: String
    let color: Color
    
    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 13, weight: .semibold))
                .foregroundColor(color)
            
            Text(text)
                .font(.system(size: 14, weight: .medium, design: .rounded))
                .foregroundColor(.white.opacity(0.95))
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
        .background(
            ZStack {
                // Frosted glass background
                Capsule()
                    .fill(.ultraThinMaterial.opacity(0.6))
                
                // Subtle colored glow
                Capsule()
                    .fill(color.opacity(0.15))
            }
        )
        .overlay(
            Capsule()
                .strokeBorder(color.opacity(0.3), lineWidth: 1)
        )
        .shadow(color: color.opacity(0.2), radius: 8, x: 0, y: 4)
    }
}

// MARK: - Floating Particles Component
struct FloatingParticles: View {
    @State private var animate = false
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                ForEach(0..<20, id: \.self) { i in
                    Circle()
                        .fill(
                            RadialGradient(
                                gradient: Gradient(colors: [
                                    Color.white.opacity(0.6),
                                    Color.white.opacity(0.0)
                                ]),
                                center: .center,
                                startRadius: 0,
                                endRadius: 3
                            )
                        )
                        .frame(width: CGFloat.random(in: 2...6), height: CGFloat.random(in: 2...6))
                        .position(
                            x: animate ? CGFloat.random(in: 0...geometry.size.width) : CGFloat.random(in: 0...geometry.size.width),
                            y: animate ? CGFloat.random(in: 0...geometry.size.height) : CGFloat.random(in: 0...geometry.size.height)
                        )
                        .animation(
                            Animation.easeInOut(duration: Double.random(in: 3...8))
                                .repeatForever(autoreverses: true)
                                .delay(Double.random(in: 0...2)),
                            value: animate
                        )
                }
            }
            .onAppear {
                animate = true
            }
        }
        .ignoresSafeArea()
    }
}

#Preview {
    let viewModel = CardsViewModel()
    let card = Card()
    return CardDetailView(cardId: card.id, viewModel: viewModel)
        .modelContainer(for: Card.self, inMemory: true)
}
