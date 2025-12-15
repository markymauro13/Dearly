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
    @State private var showBulkDeleteConfirmation = false
    @FocusState private var isSearchFocused: Bool
    
    // Check if running in DEBUG mode for dev settings visibility
    #if DEBUG
    private let showDevButton = true
    #else
    private let showDevButton = false
    #endif
    
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
                    // Search bar (when cards exist)
                    if !viewModel.cards.isEmpty {
                        SearchBarView(
                            searchText: $viewModel.searchText,
                            isSearchFocused: $isSearchFocused
                        )
                        .padding(.horizontal, 20)
                        .padding(.top, 8)
                        .padding(.bottom, 4)
                    }
                    
                    // Sort options - modern pill design (hide when in selection mode)
                    if !viewModel.cards.isEmpty && !viewModel.isSelectionMode {
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
                        .padding(.bottom, 8)
                    }
                    
                    // Selection mode toolbar
                    if viewModel.isSelectionMode {
                        SelectionToolbar(viewModel: viewModel, showDeleteConfirmation: $showBulkDeleteConfirmation)
                            .padding(.horizontal, 20)
                            .padding(.vertical, 12)
                    }
                    
                    // Main content
                    if viewModel.cards.isEmpty {
                        EmptyStateView()
                    } else if viewModel.isSearching && viewModel.sortedCards.isEmpty {
                        EmptySearchResultsView(searchText: viewModel.searchText)
                    } else if viewModel.sortOption == .favorites && viewModel.sortedCards.isEmpty {
                        EmptyFavoritesView()
                    } else {
                        CardsGridView(viewModel: viewModel)
                    }
                }
                
                // Floating Action Button - warm elegant design (hide in selection mode)
                if !viewModel.isSelectionMode {
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
            }
            .navigationTitle("")
            .navigationBarTitleDisplayMode(.inline)
            .preferredColorScheme(.light)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    if viewModel.isSelectionMode {
                        Text("\(viewModel.selectedCardsCount) Selected")
                            .font(.system(size: 17, weight: .semibold, design: .rounded))
                            .foregroundColor(Color(red: 0.40, green: 0.32, blue: 0.32))
                    } else {
                        Text("Dearly")
                            .font(.custom("Snell Roundhand", size: 30))
                            .foregroundColor(Color(red: 0.40, green: 0.32, blue: 0.32))
                    }
                }
            }
            .toolbar {
                // Leading toolbar items
                ToolbarItem(placement: .topBarLeading) {
                    if viewModel.isSelectionMode {
                        Button("Cancel") {
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                viewModel.exitSelectionMode()
                            }
                        }
                        .foregroundColor(Color(red: 0.85, green: 0.55, blue: 0.55))
                    } else if showDevButton {
                        Button(action: {
                            showingDevSettings = true
                        }) {
                            Image(systemName: "hammer.circle.fill")
                                .font(.system(size: 20))
                                .foregroundColor(.orange)
                        }
                    }
                }
                
                // Trailing toolbar items
                ToolbarItem(placement: .topBarTrailing) {
                    if viewModel.isSelectionMode {
                        // Select all / Deselect all button
                        Button(action: {
                            let impact = UIImpactFeedbackGenerator(style: .light)
                            impact.impactOccurred()
                            if viewModel.allCardsSelected {
                                viewModel.deselectAllCards()
                            } else {
                                viewModel.selectAllCards()
                            }
                        }) {
                            Text(viewModel.allCardsSelected ? "Deselect All" : "Select All")
                                .font(.system(size: 15, weight: .medium))
                                .foregroundColor(Color(red: 0.85, green: 0.55, blue: 0.55))
                        }
                    } else {
                        HStack(spacing: 16) {
                            // Select mode button (only show when cards exist)
                            if !viewModel.cards.isEmpty {
                                Button(action: {
                                    let impact = UIImpactFeedbackGenerator(style: .light)
                                    impact.impactOccurred()
                                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                        viewModel.enterSelectionMode()
                                    }
                                }) {
                                    Image(systemName: "checkmark.circle")
                                        .font(.system(size: 20))
                                        .foregroundColor(.black)
                                }
                            }
                            
                            // Filter menu
                            if !viewModel.availableOccasions.isEmpty {
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
        .alert("Delete \(viewModel.selectedCardsCount) Cards?", isPresented: $showBulkDeleteConfirmation) {
            Button("Cancel", role: .cancel) { }
            Button("Delete", role: .destructive) {
                withAnimation {
                    viewModel.deleteSelectedCards()
                }
            }
        } message: {
            Text("These cards will be permanently deleted.")
        }
    }
}

// MARK: - Search Bar Component
struct SearchBarView: View {
    @Binding var searchText: String
    var isSearchFocused: FocusState<Bool>.Binding
    
    var body: some View {
        HStack(spacing: 12) {
            HStack(spacing: 10) {
                Image(systemName: "magnifyingglass")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(Color(red: 0.5, green: 0.45, blue: 0.45))
                
                TextField("Search by sender, occasion, or notes...", text: $searchText)
                    .font(.system(size: 15, design: .rounded))
                    .foregroundColor(Color(red: 0.3, green: 0.25, blue: 0.25))
                    .focused(isSearchFocused)
                
                if !searchText.isEmpty {
                    Button(action: {
                        searchText = ""
                        isSearchFocused.wrappedValue = false
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 16))
                            .foregroundColor(Color(red: 0.6, green: 0.55, blue: 0.55))
                    }
                }
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 11)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.white)
                    .shadow(color: Color(red: 0.5, green: 0.4, blue: 0.4).opacity(0.08), radius: 8, x: 0, y: 4)
            )
        }
    }
}

// MARK: - Selection Toolbar
struct SelectionToolbar: View {
    @ObservedObject var viewModel: CardsViewModel
    @Binding var showDeleteConfirmation: Bool
    
    var body: some View {
        HStack(spacing: 16) {
            // Favorite button
            Button(action: {
                let impact = UIImpactFeedbackGenerator(style: .medium)
                impact.impactOccurred()
                viewModel.favoriteSelectedCards()
            }) {
                VStack(spacing: 4) {
                    Image(systemName: "heart.fill")
                        .font(.system(size: 20))
                    Text("Favorite")
                        .font(.system(size: 11, weight: .medium, design: .rounded))
                }
                .foregroundColor(viewModel.selectedCardsCount > 0 ? Color(red: 0.95, green: 0.45, blue: 0.50) : .gray)
            }
            .disabled(viewModel.selectedCardsCount == 0)
            
            Spacer()
            
            // Unfavorite button
            Button(action: {
                let impact = UIImpactFeedbackGenerator(style: .medium)
                impact.impactOccurred()
                viewModel.unfavoriteSelectedCards()
            }) {
                VStack(spacing: 4) {
                    Image(systemName: "heart.slash")
                        .font(.system(size: 20))
                    Text("Unfavorite")
                        .font(.system(size: 11, weight: .medium, design: .rounded))
                }
                .foregroundColor(viewModel.selectedCardsCount > 0 ? Color(red: 0.5, green: 0.45, blue: 0.45) : .gray)
            }
            .disabled(viewModel.selectedCardsCount == 0)
            
            Spacer()
            
            // Delete button
            Button(action: {
                let impact = UIImpactFeedbackGenerator(style: .medium)
                impact.impactOccurred()
                showDeleteConfirmation = true
            }) {
                VStack(spacing: 4) {
                    Image(systemName: "trash.fill")
                        .font(.system(size: 20))
                    Text("Delete")
                        .font(.system(size: 11, weight: .medium, design: .rounded))
                }
                .foregroundColor(viewModel.selectedCardsCount > 0 ? .red : .gray)
            }
            .disabled(viewModel.selectedCardsCount == 0)
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white)
                .shadow(color: Color.black.opacity(0.06), radius: 8, x: 0, y: 4)
        )
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

// MARK: - Empty Favorites View
struct EmptyFavoritesView: View {
    var body: some View {
        VStack(spacing: 24) {
            Spacer()
            
            // Star icon with subtle glow
            ZStack {
                Circle()
                    .fill(Color(red: 0.95, green: 0.90, blue: 0.88).opacity(0.6))
                    .frame(width: 120, height: 120)
                    .blur(radius: 20)
                
                Image(systemName: "star.fill")
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
                Text("No Favorites Yet")
                    .font(.custom("Snell Roundhand", size: 28))
                    .foregroundColor(Color(red: 0.35, green: 0.30, blue: 0.30))
                
                Text("Mark your most cherished cards as favorites\nby tapping the heart icon.")
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

// MARK: - Empty Search Results View
struct EmptySearchResultsView: View {
    let searchText: String
    
    var body: some View {
        VStack(spacing: 24) {
            Spacer()
            
            // Search icon with subtle glow
            ZStack {
                Circle()
                    .fill(Color(red: 0.95, green: 0.90, blue: 0.88).opacity(0.6))
                    .frame(width: 120, height: 120)
                    .blur(radius: 20)
                
                Image(systemName: "magnifyingglass")
                    .font(.system(size: 50, weight: .light))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [
                                Color(red: 0.70, green: 0.65, blue: 0.65),
                                Color(red: 0.55, green: 0.50, blue: 0.50)
                            ],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
            }
            
            VStack(spacing: 12) {
                Text("No Results")
                    .font(.custom("Snell Roundhand", size: 28))
                    .foregroundColor(Color(red: 0.35, green: 0.30, blue: 0.30))
                
                Text("No cards match \"\(searchText)\"\nTry searching by sender, occasion, or notes.")
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
                    ZStack(alignment: .topLeading) {
                        CardItemView(
                            card: card,
                            isSelectionMode: viewModel.isSelectionMode,
                            isSelected: viewModel.isCardSelected(card),
                            onTap: {
                                if viewModel.isSelectionMode {
                                    let impact = UIImpactFeedbackGenerator(style: .light)
                                    impact.impactOccurred()
                                    viewModel.toggleCardSelection(card)
                                } else {
                                    selectedCard = card
                                }
                            },
                            onFavoriteToggle: {
                                viewModel.toggleFavorite(for: card)
                            }
                        )
                        
                        // Selection checkbox overlay
                        if viewModel.isSelectionMode {
                            SelectionCheckbox(isSelected: viewModel.isCardSelected(card))
                                .padding(8)
                        }
                    }
                    .onLongPressGesture {
                        if !viewModel.isSelectionMode {
                            // Haptic feedback
                            let impact = UIImpactFeedbackGenerator(style: .medium)
                            impact.impactOccurred()
                            
                            // Enter selection mode and select this card
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                viewModel.enterSelectionMode()
                                viewModel.toggleCardSelection(card)
                            }
                        }
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

// MARK: - Selection Checkbox
struct SelectionCheckbox: View {
    let isSelected: Bool
    
    var body: some View {
        ZStack {
            Circle()
                .fill(isSelected ? Color(red: 0.85, green: 0.55, blue: 0.55) : Color.white.opacity(0.9))
                .frame(width: 26, height: 26)
                .shadow(color: .black.opacity(0.15), radius: 4, x: 0, y: 2)
            
            if isSelected {
                Image(systemName: "checkmark")
                    .font(.system(size: 13, weight: .bold))
                    .foregroundColor(.white)
            } else {
                Circle()
                    .strokeBorder(Color(red: 0.5, green: 0.45, blue: 0.45).opacity(0.5), lineWidth: 2)
                    .frame(width: 26, height: 26)
            }
        }
    }
}

#Preview {
    HomeView()
        .modelContainer(for: Card.self, inMemory: true)
}
