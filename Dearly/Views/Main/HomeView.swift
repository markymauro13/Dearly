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
                    // Top section with sort options
                    if !viewModel.cards.isEmpty {
                        HStack(spacing: 12) {
                            // Sort icon
                            Image(systemName: "line.3.horizontal.decrease.circle")
                                .foregroundColor(.gray)
                                .font(.system(size: 20))
                            
                            // Sort options
                            ForEach(SortOption.allCases, id: \.self) { option in
                                Button(action: {
                                    viewModel.sortOption = option
                                }) {
                                    Text(option.rawValue)
                                        .font(.system(size: 14))
                                        .foregroundColor(viewModel.sortOption == option ? .primary : .secondary)
                                        .padding(.horizontal, 12)
                                        .padding(.vertical, 6)
                                        .background(viewModel.sortOption == option ? Color.secondary.opacity(0.2) : Color.clear)
                                        .cornerRadius(12)
                                }
                            }
                            
                            Spacer()
                        }
                        .padding(.horizontal, 20)
                        .padding(.vertical, 12)
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
                            viewModel.isShowingScanner = true
                        }) {
                            Image(systemName: "plus")
                                .font(.system(size: 28, weight: .semibold))
                                .foregroundColor(.white)
                                .frame(width: 64, height: 64)
                                .background(Color.blue)
                                .clipShape(Circle())
                                .shadow(color: .black.opacity(0.3), radius: 8, x: 0, y: 4)
                        }
                        .padding(.trailing, 24)
                        .padding(.bottom, 24)
                    }
                }
            }
            .navigationTitle("Dearly")
            .navigationBarTitleDisplayMode(.large)
        }
        .sheet(isPresented: $viewModel.isShowingScanner) {
            ScanCardFlowView(viewModel: viewModel)
        }
    }
}

// MARK: - Empty State View
struct EmptyStateView: View {
    var body: some View {
        VStack {
            Spacer()
            
            Text("no cards to display :(")
                .font(.system(size: 16))
                .foregroundColor(.gray)
            
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
        GridItem(.flexible(), spacing: 16),
        GridItem(.flexible(), spacing: 16)
    ]
    
    var body: some View {
        ScrollView {
            LazyVGrid(columns: columns, spacing: 16) {
                ForEach(viewModel.sortedCards) { card in
                    SpinningCardView(card: card)
                        .onTapGesture {
                            selectedCard = card
                        }
                        .onLongPressGesture {
                            // Haptic feedback
                            let impact = UIImpactFeedbackGenerator(style: .medium)
                            impact.impactOccurred()
                            
                            cardToDelete = card
                            showDeleteConfirmation = true
                        }
                }
            }
            .padding()
        }
        .fullScreenCover(item: $selectedCard) { card in
            CardDetailView(card: card)
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


