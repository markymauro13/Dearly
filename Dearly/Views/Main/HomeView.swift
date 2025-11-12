//
//  HomeView.swift
//  Dearly
//
//  Created by Mark Mauro on 10/28/25.
//

import SwiftUI

struct HomeView: View {
    @StateObject private var viewModel = CardsViewModel()
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color(UIColor.systemBackground).ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Sort options - clean and minimal
                    if !viewModel.cards.isEmpty {
                        HStack(spacing: 16) {
                            ForEach(SortOption.allCases, id: \.self) { option in
                                Button(action: {
                                    withAnimation(.easeInOut(duration: 0.2)) {
                                        viewModel.sortOption = option
                                    }
                                }) {
                                    Text(option.rawValue)
                                        .font(.system(size: 15, weight: viewModel.sortOption == option ? .semibold : .regular))
                                        .foregroundColor(viewModel.sortOption == option ? .primary : .secondary)
                                }
                            }
                            Spacer()
                        }
                        .padding(.horizontal, 20)
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
                
                // Floating Action Button
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
                                .font(.system(size: 24, weight: .semibold))
                                .foregroundColor(.white)
                                .frame(width: 60, height: 60)
                                .background(
                                    LinearGradient(
                                        gradient: Gradient(colors: [Color.blue, Color.blue.opacity(0.8)]),
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .clipShape(Circle())
                                .shadow(color: Color.blue.opacity(0.4), radius: 12, x: 0, y: 6)
                        }
                        .padding(.trailing, 20)
                        .padding(.bottom, 20)
                    }
                }
            }
            .navigationTitle("Dearly")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
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
                                .foregroundColor(.primary)
                        }
                    }
                }
            }
        }
        .sheet(isPresented: $viewModel.isShowingScanner) {
            ScanCardFlowView(viewModel: viewModel)
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
                .foregroundColor(.gray.opacity(0.4))
            
            VStack(spacing: 8) {
                Text("No Cards Yet")
                    .font(.system(size: 22, weight: .semibold))
                    .foregroundColor(.primary)
                
                Text("Tap the + button to scan your first card")
                    .font(.system(size: 15))
                    .foregroundColor(.secondary)
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


