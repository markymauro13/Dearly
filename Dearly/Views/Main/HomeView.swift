//
//  HomeView.swift
//  Dearly
//
//  Created by Mark Mauro on 10/28/25.
//

import SwiftUI

struct HomeView: View {
    @StateObject private var viewModel = CardsViewModel()
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = true
    @State private var showingDevSettings = false
    
    var body: some View {
        NavigationStack {
            ZStack {
                // Soft gradient background
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color(red: 0.98, green: 0.98, blue: 1.0),
                        Color.white
                    ]),
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Sort options - modern pill design
                    if !viewModel.cards.isEmpty {
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 10) {
                                ForEach(SortOption.allCases, id: \.self) { option in
                                    Button(action: {
                                        let impact = UIImpactFeedbackGenerator(style: .light)
                                        impact.impactOccurred()
                                        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                            viewModel.sortOption = option
                                        }
                                    }) {
                                        Text(option.rawValue)
                                            .font(.system(size: 14, weight: .semibold))
                                            .foregroundColor(viewModel.sortOption == option ? .white : .black.opacity(0.7))
                                            .padding(.horizontal, 18)
                                            .padding(.vertical, 10)
                                            .background(
                                                Group {
                                                    if viewModel.sortOption == option {
                                                        Capsule()
                                                            .fill(Color(red: 0.42, green: 0.67, blue: 1.0))
                                                            .shadow(color: Color(red: 0.42, green: 0.67, blue: 1.0).opacity(0.3), radius: 8, x: 0, y: 4)
                                                    } else {
                                                        Capsule()
                                                            .fill(Color.white)
                                                            .shadow(color: .black.opacity(0.06), radius: 4, x: 0, y: 2)
                                                    }
                                                }
                                            )
                                    }
                                }
                            }
                            .padding(.horizontal, 20)
                        }
                        .padding(.top, 8)
                        .padding(.bottom, 16)
                    }
                    
                    // Main content
                    if viewModel.cards.isEmpty {
                        EmptyStateView()
                    } else {
                        CardsGridView(viewModel: viewModel)
                    }
                }
                
                // Floating Action Button - elegant design
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
                                .frame(width: 56, height: 56)
                                .background(
                                    ZStack {
                                        // Subtle gradient
                                        LinearGradient(
                                            gradient: Gradient(colors: [
                                                Color(red: 0.42, green: 0.67, blue: 1.0),
                                                Color(red: 0.35, green: 0.60, blue: 0.95)
                                            ]),
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        )
                                    }
                                )
                                .clipShape(Circle())
                                .shadow(color: Color(red: 0.42, green: 0.67, blue: 1.0).opacity(0.3), radius: 16, x: 0, y: 8)
                                .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
                        }
                        .padding(.trailing, 24)
                        .padding(.bottom, 24)
                    }
                }
            }
            .navigationTitle("Dearly")
            .navigationBarTitleDisplayMode(.large)
            .preferredColorScheme(.light)
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

// MARK: - Empty State View
struct EmptyStateView: View {
    var body: some View {
        VStack(spacing: 20) {
            Spacer()
            
            Image(systemName: "heart.text.square")
                .font(.system(size: 60))
                .foregroundColor(.gray.opacity(0.5))
            
            VStack(spacing: 8) {
                Text("No Cards Yet")
                    .font(.system(size: 24, weight: .bold, design: .rounded))
                    .foregroundColor(.black)
                
                Text("Tap the + button to scan your first card")
                    .font(.system(size: 15, design: .rounded))
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.center)
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
                    SpinningCardView(
                        card: card,
                        onDoubleTap: {
                            // Haptic feedback
                            let impact = UIImpactFeedbackGenerator(style: .medium)
                            impact.impactOccurred()
                            
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
}


