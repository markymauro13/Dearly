//
//  ScanCardFlowView.swift
//  Dearly
//
//  Created by Mark Mauro on 10/28/25.
//

import SwiftUI
import SwiftData

// MARK: - Card Type
enum CardType: String, CaseIterable {
    case traditional = "traditional"  // 4 sides: front, back, inside left, inside right
    case doubleSided = "doubleSided"  // 2 sides: front, back only
    
    var displayName: String {
        switch self {
        case .traditional: return "Folding Card"
        case .doubleSided: return "Flat Card"
        }
    }
    
    var description: String {
        switch self {
        case .traditional: return "Opens like a book with 4 sides"
        case .doubleSided: return "Simple 2-sided postcard or flat card"
        }
    }
    
    var icon: String {
        switch self {
        case .traditional: return "book.pages"
        case .doubleSided: return "rectangle.portrait.on.rectangle.portrait"
        }
    }
    
    var sideCount: Int {
        switch self {
        case .traditional: return 4
        case .doubleSided: return 2
        }
    }
}

enum ScanSide: Int, CaseIterable {
    case front = 0
    case back = 1
    case insideLeft = 2
    case insideRight = 3
    
    var title: String {
        switch self {
        case .front: return "Front"
        case .back: return "Back"
        case .insideLeft: return "Inside Left"
        case .insideRight: return "Inside Right"
        }
    }
    
    var instruction: String {
        switch self {
        case .front: return "Scan the front cover of your card"
        case .back: return "Flip the card over and scan the back"
        case .insideLeft: return "Open the card and scan the left inside page"
        case .insideRight: return "Now scan the right inside page"
        }
    }
    
    var icon: String {
        switch self {
        case .front: return "rectangle.portrait"
        case .back: return "rectangle.portrait.fill"
        case .insideLeft: return "book.closed"
        case .insideRight: return "book.closed.fill"
        }
    }
}

// MARK: - Scan Flow State
enum ScanFlowState {
    case selectingCardType
    case scanning
    case celebration
}

struct ScanCardFlowView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var viewModel: CardsViewModel
    
    @State private var flowState: ScanFlowState = .selectingCardType
    @State private var selectedCardType: CardType = .traditional
    @State private var frontImage: UIImage?
    @State private var backImage: UIImage?
    @State private var insideLeftImage: UIImage?
    @State private var insideRightImage: UIImage?
    @State private var currentScanSide: ScanSide = .front
    @State private var showScanner = false
    @State private var savedCard: Card?
    
    private var isComplete: Bool {
        switch selectedCardType {
        case .traditional:
            return frontImage != nil && backImage != nil && insideLeftImage != nil && insideRightImage != nil
        case .doubleSided:
            return frontImage != nil && backImage != nil
        }
    }
    
    private var nextSideToScan: ScanSide? {
        if frontImage == nil { return .front }
        if backImage == nil { return .back }
        if selectedCardType == .traditional {
            if insideLeftImage == nil { return .insideLeft }
            if insideRightImage == nil { return .insideRight }
        }
        return nil
    }
    
    private var completedCount: Int {
        var count = 0
        if frontImage != nil { count += 1 }
        if backImage != nil { count += 1 }
        if selectedCardType == .traditional {
            if insideLeftImage != nil { count += 1 }
            if insideRightImage != nil { count += 1 }
        }
        return count
    }
    
    private var totalSides: Int {
        selectedCardType.sideCount
    }

    var body: some View {
        NavigationStack {
            ZStack {
                // Background
                LinearGradient(
                    colors: [
                        Color(red: 1.0, green: 0.98, blue: 0.96),
                        Color(red: 0.99, green: 0.97, blue: 0.95)
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()
                
                switch flowState {
                case .selectingCardType:
                    cardTypeSelectionView
                case .scanning:
                    scanningView
                case .celebration:
                    if let card = savedCard {
                        CelebrationView(
                            card: card,
                            onAddDetails: {
                                // TODO: Navigate to add details
                                dismiss()
                            },
                            onScanAnother: {
                                resetForNewScan()
                            },
                            onDone: {
                                dismiss()
                            }
                        )
                    }
                }
            }
            .navigationTitle(flowState == .celebration ? "" : "New Card")
            .navigationBarTitleDisplayMode(.inline)
            .preferredColorScheme(.light)
            .toolbar {
                if flowState != .celebration {
                    ToolbarItem(placement: .cancellationAction) {
                        Button("Cancel") { dismiss() }
                    }
                }
                if flowState == .scanning {
                    ToolbarItem(placement: .confirmationAction) {
                        Button("Done") {
                            saveCard()
                        }
                        .disabled(!isComplete)
                    }
                }
            }
            .fullScreenCover(isPresented: $showScanner) {
                CardScannerView(
                    onScanComplete: { images in
                        if let firstImage = images.first {
                            handleScannedImage(firstImage, for: currentScanSide)
                        }
                        showScanner = false
                    },
                    onCancel: {
                        showScanner = false
                    }
                )
                .ignoresSafeArea()
            }
        }
    }
    
    // MARK: - Card Type Selection View
    private var cardTypeSelectionView: some View {
        VStack(spacing: 32) {
            Spacer()
            
            // Header
            VStack(spacing: 12) {
                ZStack {
                    Circle()
                        .fill(Color(red: 0.85, green: 0.55, blue: 0.55).opacity(0.15))
                        .frame(width: 80, height: 80)
                    
                    Image(systemName: "doc.viewfinder")
                        .font(.system(size: 36))
                        .foregroundColor(Color(red: 0.85, green: 0.55, blue: 0.55))
                }
                
                Text("What type of card?")
                    .font(.system(.title, design: .rounded, weight: .bold))
                    .foregroundColor(Color(red: 0.25, green: 0.20, blue: 0.20))
                
                Text("This helps us know how many sides to scan")
                    .font(.system(.subheadline, design: .rounded))
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
            
            // Card type options
            VStack(spacing: 16) {
                ForEach(CardType.allCases, id: \.self) { cardType in
                    CardTypeOptionView(
                        cardType: cardType,
                        isSelected: selectedCardType == cardType,
                        onSelect: {
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                selectedCardType = cardType
                            }
                            let impact = UIImpactFeedbackGenerator(style: .light)
                            impact.impactOccurred()
                        }
                    )
                }
            }
            .padding(.horizontal, 24)
            
            Spacer()
            
            // Continue button
            Button(action: {
                withAnimation(.easeInOut(duration: 0.3)) {
                    flowState = .scanning
                }
            }) {
                HStack {
                    Text("Continue")
                    Image(systemName: "arrow.right")
                }
                .font(.system(.headline, design: .rounded, weight: .semibold))
                .foregroundColor(.white)
                .padding()
                .frame(maxWidth: .infinity)
                .background(
                    LinearGradient(
                        colors: [
                            Color(red: 0.85, green: 0.55, blue: 0.55),
                            Color(red: 0.75, green: 0.45, blue: 0.50)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .cornerRadius(16)
                .shadow(color: Color(red: 0.80, green: 0.50, blue: 0.50).opacity(0.35), radius: 8, x: 0, y: 4)
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 32)
        }
    }
    
    // MARK: - Scanning View
    private var scanningView: some View {
        VStack(spacing: 0) {
            // Progress indicator
            ProgressHeader(completed: completedCount, total: totalSides)
                .padding(.top, 8)
            
            ScrollView {
                VStack(spacing: 24) {
                    // Header
                    VStack(spacing: 8) {
                        Text("Scan Your Card")
                            .font(.system(.title2, design: .rounded, weight: .bold))
                        
                        Text("Tap each section below to scan that side of your card")
                            .font(.system(.subheadline, design: .rounded))
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    .padding(.top, 16)
                    
                    // Card sides grid
                    if selectedCardType == .doubleSided {
                        // 2-sided layout
                        HStack(spacing: 16) {
                            ScanSlotView(
                                side: .front,
                                image: frontImage,
                                isNext: nextSideToScan == .front,
                                onTap: { startScanning(.front) },
                                onRetake: { startScanning(.front) }
                            )
                            
                            ScanSlotView(
                                side: .back,
                                image: backImage,
                                isNext: nextSideToScan == .back,
                                onTap: { startScanning(.back) },
                                onRetake: { startScanning(.back) }
                            )
                        }
                        .padding(.horizontal, 20)
                    } else {
                        // 4-sided layout
                        VStack(spacing: 16) {
                            HStack(spacing: 16) {
                                ScanSlotView(
                                    side: .front,
                                    image: frontImage,
                                    isNext: nextSideToScan == .front,
                                    onTap: { startScanning(.front) },
                                    onRetake: { startScanning(.front) }
                                )
                                
                                ScanSlotView(
                                    side: .back,
                                    image: backImage,
                                    isNext: nextSideToScan == .back,
                                    onTap: { startScanning(.back) },
                                    onRetake: { startScanning(.back) }
                                )
                            }
                            
                            HStack(spacing: 16) {
                                ScanSlotView(
                                    side: .insideLeft,
                                    image: insideLeftImage,
                                    isNext: nextSideToScan == .insideLeft,
                                    onTap: { startScanning(.insideLeft) },
                                    onRetake: { startScanning(.insideLeft) }
                                )
                                
                                ScanSlotView(
                                    side: .insideRight,
                                    image: insideRightImage,
                                    isNext: nextSideToScan == .insideRight,
                                    onTap: { startScanning(.insideRight) },
                                    onRetake: { startScanning(.insideRight) }
                                )
                            }
                        }
                        .padding(.horizontal, 20)
                    }
                    
                    // Next step hint
                    if let nextSide = nextSideToScan {
                        NextStepHint(side: nextSide) {
                            startScanning(nextSide)
                        }
                        .padding(.horizontal, 20)
                        .padding(.top, 8)
                    }
                    
                    Spacer(minLength: 100)
                }
            }
            
            // Bottom button
            VStack(spacing: 12) {
                if isComplete {
                    Button(action: saveCard) {
                        HStack {
                            Image(systemName: "checkmark.circle.fill")
                            Text("Save Card")
                        }
                        .font(.system(.headline, design: .rounded, weight: .semibold))
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(
                            LinearGradient(
                                colors: [
                                    Color(red: 0.40, green: 0.75, blue: 0.45),
                                    Color(red: 0.30, green: 0.65, blue: 0.40)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .cornerRadius(16)
                        .shadow(color: Color(red: 0.35, green: 0.70, blue: 0.40).opacity(0.35), radius: 8, x: 0, y: 4)
                    }
                } else if let nextSide = nextSideToScan {
                    Button(action: { startScanning(nextSide) }) {
                        HStack {
                            Image(systemName: "camera.fill")
                            Text("Scan \(nextSide.title)")
                        }
                        .font(.system(.headline, design: .rounded, weight: .semibold))
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(
                            LinearGradient(
                                colors: [
                                    Color(red: 0.85, green: 0.55, blue: 0.55),
                                    Color(red: 0.75, green: 0.45, blue: 0.50)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .cornerRadius(16)
                        .shadow(color: Color(red: 0.80, green: 0.50, blue: 0.50).opacity(0.35), radius: 8, x: 0, y: 4)
                    }
                }
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 24)
        }
    }
    
    private func startScanning(_ side: ScanSide) {
        let impact = UIImpactFeedbackGenerator(style: .light)
        impact.impactOccurred()
        currentScanSide = side
        showScanner = true
    }
    
    private func handleScannedImage(_ image: UIImage, for side: ScanSide) {
        switch side {
        case .front:
            frontImage = image
        case .back:
            backImage = image
        case .insideLeft:
            insideLeftImage = image
        case .insideRight:
            insideRightImage = image
        }
        
        // Haptic feedback for success
        let notification = UINotificationFeedbackGenerator()
        notification.notificationOccurred(.success)
    }
    
    private func saveCard() {
        // Save card with images via ViewModel (images saved to file system)
        let card = viewModel.addCard(
            frontImage: frontImage,
            backImage: backImage,
            insideLeftImage: selectedCardType == .traditional ? insideLeftImage : nil,
            insideRightImage: selectedCardType == .traditional ? insideRightImage : nil
        )
        
        savedCard = card
        
        // Always switch to "Newest" so user sees their newly scanned card
        viewModel.sortOption = .newest
        viewModel.selectedOccasionFilter = nil
        
        // Trigger celebration
        withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
            flowState = .celebration
        }
        
        // Big success haptic
        let notification = UINotificationFeedbackGenerator()
        notification.notificationOccurred(.success)
    }
    
    private func resetForNewScan() {
        frontImage = nil
        backImage = nil
        insideLeftImage = nil
        insideRightImage = nil
        savedCard = nil
        currentScanSide = .front
        
        withAnimation(.easeInOut(duration: 0.3)) {
            flowState = .selectingCardType
        }
    }
}

// MARK: - Card Type Option View
struct CardTypeOptionView: View {
    let cardType: CardType
    let isSelected: Bool
    let onSelect: () -> Void
    
    var body: some View {
        Button(action: onSelect) {
            HStack(spacing: 16) {
                // Icon
                ZStack {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(isSelected ? 
                              Color(red: 0.85, green: 0.55, blue: 0.55).opacity(0.15) : 
                              Color.gray.opacity(0.08))
                        .frame(width: 56, height: 56)
                    
                    Image(systemName: cardType.icon)
                        .font(.system(size: 24))
                        .foregroundColor(isSelected ? 
                                        Color(red: 0.85, green: 0.55, blue: 0.55) : 
                                        Color.gray.opacity(0.6))
                }
                
                // Text
                VStack(alignment: .leading, spacing: 4) {
                    Text(cardType.displayName)
                        .font(.system(.headline, design: .rounded, weight: .semibold))
                        .foregroundColor(Color(red: 0.25, green: 0.20, blue: 0.20))
                    
                    Text(cardType.description)
                        .font(.system(size: 13, design: .rounded))
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                // Selection indicator
                ZStack {
                    Circle()
                        .strokeBorder(isSelected ? 
                                     Color(red: 0.85, green: 0.55, blue: 0.55) : 
                                     Color.gray.opacity(0.3), lineWidth: 2)
                        .frame(width: 24, height: 24)
                    
                    if isSelected {
                        Circle()
                            .fill(Color(red: 0.85, green: 0.55, blue: 0.55))
                            .frame(width: 14, height: 14)
                    }
                }
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.white)
                    .shadow(color: isSelected ? 
                           Color(red: 0.85, green: 0.55, blue: 0.55).opacity(0.2) : 
                           Color.black.opacity(0.06), radius: 8, x: 0, y: 4)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .strokeBorder(isSelected ? 
                                 Color(red: 0.85, green: 0.55, blue: 0.55).opacity(0.5) : 
                                 Color.clear, lineWidth: 2)
            )
        }
    }
}

// MARK: - Progress Header
struct ProgressHeader: View {
    let completed: Int
    let total: Int
    
    var body: some View {
        VStack(spacing: 8) {
            HStack(spacing: 4) {
                ForEach(0..<total, id: \.self) { index in
                    Capsule()
                        .fill(index < completed ? 
                              Color(red: 0.85, green: 0.55, blue: 0.55) : 
                              Color.gray.opacity(0.2))
                        .frame(height: 4)
                }
            }
            .padding(.horizontal, 40)
            
            Text("\(completed) of \(total) sides scanned")
                .font(.system(size: 12, weight: .medium, design: .rounded))
                .foregroundColor(.secondary)
        }
    }
}

// MARK: - Scan Slot View
struct ScanSlotView: View {
    let side: ScanSide
    let image: UIImage?
    let isNext: Bool
    let onTap: () -> Void
    let onRetake: () -> Void
    
    var body: some View {
        VStack(spacing: 8) {
            ZStack {
                if let img = image {
                    // Scanned image
                    Image(uiImage: img)
                        .resizable()
                        .scaledToFill()
                        .frame(height: 140)
                        .clipped()
                        .cornerRadius(4)
                        .overlay(
                            // Checkmark badge
                            VStack {
                                HStack {
                                    Spacer()
                                    Image(systemName: "checkmark.circle.fill")
                                        .font(.system(size: 24))
                                        .foregroundColor(.green)
                                        .background(Circle().fill(.white).padding(2))
                                        .padding(8)
                                }
                                Spacer()
                            }
                        )
                        .overlay(
                            // Retake button
                            VStack {
                                Spacer()
                                Button(action: onRetake) {
                                    Text("Retake")
                                        .font(.system(size: 11, weight: .semibold, design: .rounded))
                                        .foregroundColor(.white)
                                        .padding(.horizontal, 12)
                                        .padding(.vertical, 6)
                                        .background(Color.black.opacity(0.6))
                                        .cornerRadius(12)
                                }
                                .padding(8)
                            }
                        )
                } else {
                    // Empty slot
                    RoundedRectangle(cornerRadius: 4)
                        .fill(
                            LinearGradient(
                                colors: isNext ? [
                                    Color(red: 1.0, green: 0.95, blue: 0.95),
                                    Color(red: 0.98, green: 0.92, blue: 0.92)
                                ] : [
                                    Color(red: 0.97, green: 0.97, blue: 0.97),
                                    Color(red: 0.94, green: 0.94, blue: 0.94)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(height: 140)
                        .overlay(
                            RoundedRectangle(cornerRadius: 4)
                                .strokeBorder(
                                    isNext ? Color(red: 0.85, green: 0.55, blue: 0.55).opacity(0.5) : Color.gray.opacity(0.2),
                                    style: StrokeStyle(lineWidth: isNext ? 2 : 1.5, dash: isNext ? [] : [6])
                                )
                        )
                        .overlay(
                            VStack(spacing: 8) {
                                Image(systemName: isNext ? "camera.fill" : side.icon)
                                    .font(.system(size: 28))
                                    .foregroundColor(isNext ? Color(red: 0.85, green: 0.55, blue: 0.55) : .gray.opacity(0.4))
                                
                                if isNext {
                                    Text("Tap to scan")
                                        .font(.system(size: 11, weight: .medium, design: .rounded))
                                        .foregroundColor(Color(red: 0.85, green: 0.55, blue: 0.55))
                                }
                            }
                        )
                        .onTapGesture {
                            onTap()
                        }
                }
            }
            .shadow(color: Color.black.opacity(0.08), radius: 8, x: 0, y: 4)
            
            // Label
            HStack(spacing: 4) {
                if image != nil {
                    Image(systemName: "checkmark")
                        .font(.system(size: 10, weight: .bold))
                        .foregroundColor(.green)
                }
                
                Text(side.title)
                    .font(.system(size: 13, weight: .semibold, design: .rounded))
                    .foregroundColor(image != nil ? Color(red: 0.3, green: 0.3, blue: 0.3) : .gray)
            }
        }
        .frame(maxWidth: .infinity)
    }
}

// MARK: - Next Step Hint
struct NextStepHint: View {
    let side: ScanSide
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 12) {
                ZStack {
                    Circle()
                        .fill(Color(red: 0.85, green: 0.55, blue: 0.55).opacity(0.15))
                        .frame(width: 44, height: 44)
                    
                    Image(systemName: "arrow.right")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(Color(red: 0.85, green: 0.55, blue: 0.55))
                }
                
                VStack(alignment: .leading, spacing: 2) {
                    Text("Next: \(side.title)")
                        .font(.system(size: 15, weight: .semibold, design: .rounded))
                        .foregroundColor(Color(red: 0.3, green: 0.25, blue: 0.25))
                    
                    Text(side.instruction)
                        .font(.system(size: 13, design: .rounded))
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.gray.opacity(0.5))
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.white)
                    .shadow(color: Color.black.opacity(0.06), radius: 8, x: 0, y: 4)
            )
        }
    }
}

#Preview {
    ScanCardFlowView(viewModel: CardsViewModel())
        .modelContainer(for: Card.self, inMemory: true)
}
