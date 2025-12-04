//
//  HomeView.swift
//  Dearly
//
//  Created by Mark Mauro on 10/28/25.
//

import SwiftUI
import SwiftData

struct HomeView: View {
    @Environment(\.modelContext) private var modelContext
    @StateObject private var viewModel = CardsViewModel()
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = true
    @State private var showingDevSettings = false
    
    var body: some View {
        NavigationStack {
            ZStack {
                // Warm cream gradient background
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color(red: 1.0, green: 0.98, blue: 0.96),  // Warm cream
                        Color(red: 0.99, green: 0.97, blue: 0.95), // Soft ivory
                        Color(red: 1.0, green: 0.99, blue: 0.98)   // Pearl white
                    ]),
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Sort options - modern pill design
                    if !viewModel.cards.isEmpty {
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 12) {
                                ForEach(SortOption.allCases, id: \.self) { option in
                                    SortButton(
                                        option: option,
                                        isSelected: viewModel.sortOption == option,
                                        action: {
                                            let impact = UIImpactFeedbackGenerator(style: .light)
                                            impact.impactOccurred()
                                            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                                viewModel.sortOption = option
                                            }
                                        }
                                    )
                                }
                            }
                            .padding(.horizontal, 20)
                            .padding(.vertical, 12)
                        }
                        .background(
                            // Extended background to prevent shadow clipping
                            Color(red: 1.0, green: 0.98, blue: 0.96)
                                .ignoresSafeArea(edges: .horizontal)
                        )
                        .padding(.bottom, 12)
                    }
                    
                    // Main content
                    if viewModel.cards.isEmpty {
                        EmptyStateView()
                    } else {
                        CardsGridView(viewModel: viewModel)
                    }
                }
                
                // Floating Action Button - warm elegant design
                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        Button(action: {
                            let impact = UIImpactFeedbackGenerator(style: .light)
                            impact.impactOccurred()
                            viewModel.isShowingScanner = true
                        }) {
                            Image(systemName: "plus")
                                .font(.system(size: 22, weight: .semibold))
                                .foregroundColor(.white)
                                .frame(width: 60, height: 60)
                                .background(
                                    ZStack {
                                        // Warm rose gradient
                                        LinearGradient(
                                            gradient: Gradient(colors: [
                                                Color(red: 0.90, green: 0.55, blue: 0.55),
                                                Color(red: 0.78, green: 0.42, blue: 0.48)
                                            ]),
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        )
                                    }
                                )
                                .clipShape(Circle())
                                .shadow(color: Color(red: 0.85, green: 0.50, blue: 0.50).opacity(0.4), radius: 16, x: 0, y: 8)
                                .shadow(color: .black.opacity(0.08), radius: 4, x: 0, y: 2)
                        }
                        .padding(.trailing, 24)
                        .padding(.bottom, 24)
                    }
                }
            }
            .navigationTitle("")
            .navigationBarTitleDisplayMode(.inline)
            .preferredColorScheme(.light)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("Dearly")
                        .font(.custom("Snell Roundhand", size: 30))
                        .foregroundColor(Color(red: 0.40, green: 0.32, blue: 0.32))
                }
            }
            .toolbar {
                // Developer Settings Button
                ToolbarItem(placement: .topBarLeading) {
                    Button(action: {
                        showingDevSettings = true
                    }) {
                        Image(systemName: "hammer.circle.fill")
                            .font(.system(size: 20))
                            .foregroundColor(.orange)
                    }
                }
                
                if !viewModel.availableOccasions.isEmpty {
                    ToolbarItem(placement: .topBarTrailing) {
                        Menu {
                            Button(action: {
                                viewModel.selectedOccasionFilter = nil
                            }) {
                                Label(
                                    viewModel.selectedOccasionFilter == nil ? "All Cards ✓" : "All Cards",
                                    systemImage: "square.grid.2x2"
                                )
                            }
                            
                            Divider()
                            
                            ForEach(viewModel.availableOccasions, id: \.self) { occasion in
                                Button(action: {
                                    viewModel.selectedOccasionFilter = occasion
                                }) {
                                    Label(
                                        viewModel.selectedOccasionFilter == occasion ? "\(occasion) ✓" : occasion,
                                        systemImage: "tag"
                                    )
                                }
                            }
                        } label: {
                            Image(systemName: viewModel.selectedOccasionFilter == nil ? "line.3.horizontal.decrease.circle" : "line.3.horizontal.decrease.circle.fill")
                                .font(.system(size: 20))
                                .foregroundColor(.black)
                        }
                    }
                }
            }
            .onAppear {
                viewModel.configure(with: modelContext)
            }
        }
        .sheet(isPresented: $viewModel.isShowingScanner) {
            ScanCardFlowView(viewModel: viewModel)
        }
        .sheet(isPresented: $showingDevSettings) {
            DeveloperSettingsView(
                viewModel: viewModel,
                hasCompletedOnboarding: $hasCompletedOnboarding
            )
        }
    }
}

// MARK: - Sort Button Component
struct SortButton: View {
    let option: SortOption
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(option.rawValue)
                .font(.system(size: 13, weight: .medium, design: .rounded))
                .foregroundColor(isSelected ? .white : Color(red: 0.4, green: 0.35, blue: 0.35))
                .padding(.horizontal, 16)
                .padding(.vertical, 9)
                .background(
                    ZStack {
                        if isSelected {
                            Capsule()
                                .fill(
                                    LinearGradient(
                                        colors: [
                                            Color(red: 0.85, green: 0.55, blue: 0.55),
                                            Color(red: 0.75, green: 0.45, blue: 0.50)
                                        ],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                        } else {
                            Capsule()
                                .fill(Color.white.opacity(0.9))
                        }
                    }
                )
                .shadow(
                    color: isSelected ? 
                        Color(red: 0.85, green: 0.55, blue: 0.55).opacity(0.35) : 
                        Color(red: 0.6, green: 0.5, blue: 0.5).opacity(0.08),
                    radius: isSelected ? 8 : 6,
                    x: 0,
                    y: isSelected ? 4 : 3
                )
        }
    }
}

// MARK: - Empty State View
struct EmptyStateView: View {
    var body: some View {
        VStack(spacing: 24) {
            Spacer()
            
            // Warm heart icon with subtle glow
            ZStack {
                Circle()
                    .fill(Color(red: 0.95, green: 0.90, blue: 0.88).opacity(0.6))
                    .frame(width: 120, height: 120)
                    .blur(radius: 20)
                
                Image(systemName: "heart.fill")
                    .font(.system(size: 50))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [
                                Color(red: 0.90, green: 0.60, blue: 0.60),
                                Color(red: 0.80, green: 0.50, blue: 0.55)
                            ],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
            }
            
            VStack(spacing: 12) {
                Text("Your Memories Await")
                    .font(.custom("Snell Roundhand", size: 28))
                    .foregroundColor(Color(red: 0.35, green: 0.30, blue: 0.30))
                
                Text("Every card holds a piece of someone's heart.\nTap + to preserve your first cherished memory.")
                    .font(.system(size: 15, weight: .regular, design: .rounded))
                    .foregroundColor(Color(red: 0.5, green: 0.45, blue: 0.45))
                    .multilineTextAlignment(.center)
                    .lineSpacing(4)
                    .padding(.horizontal, 40)
            }
            
            Spacer()
        }
    }
}

// MARK: - Cards Grid View
struct CardsGridView: View {
    @ObservedObject var viewModel: CardsViewModel
    @State private var selectedCard: Card?
    @State private var cardToDelete: Card?
    @State private var showDeleteConfirmation = false
    
    let columns = [
        GridItem(.flexible(), spacing: 20),
        GridItem(.flexible(), spacing: 20)
    ]
    
    var body: some View {
        ScrollView {
            LazyVGrid(columns: columns, spacing: 20) {
                ForEach(viewModel.sortedCards) { card in
                    CardItemView(
                        card: card,
                        onTap: {
                            selectedCard = card
                        },
                        onFavoriteToggle: {
                            viewModel.toggleFavorite(for: card)
                        }
                    )
                    .onLongPressGesture {
                        // Haptic feedback
                        let impact = UIImpactFeedbackGenerator(style: .medium)
                        impact.impactOccurred()
                        
                        cardToDelete = card
                        showDeleteConfirmation = true
                    }
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 8)
            .padding(.bottom, 100)
        }
        .fullScreenCover(item: $selectedCard) { card in
            CardDetailView(cardId: card.id, viewModel: viewModel)
        }
        .alert("Delete Card?", isPresented: $showDeleteConfirmation) {
            Button("Cancel", role: .cancel) {
                cardToDelete = nil
            }
            Button("Delete", role: .destructive) {
                if let card = cardToDelete {
                    withAnimation {
                        viewModel.deleteCard(card)
                    }
                    cardToDelete = nil
                }
            }
        } message: {
            Text("This card will be permanently deleted.")
        }
    }
}

#Preview {
    HomeView()
        .modelContainer(for: Card.self, inMemory: true)
}
