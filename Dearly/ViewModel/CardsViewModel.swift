//
//  CardsViewModel.swift
//  Dearly
//
//  Created by Mark Mauro on 10/28/25.
//

import Foundation
import SwiftUI
import SwiftData

enum SortOption: String, CaseIterable {
    case newest = "Newest"
    case oldest = "Oldest"
    case favorites = "Favorites"
}

@MainActor
class CardsViewModel: ObservableObject {
    @Published var cards: [Card] = []
    @Published var isShowingScanner = false
    @Published var sortOption: SortOption = .newest
    @Published var selectedOccasionFilter: String? = nil
    
    private var repository: CardRepository?
    private let imageStorage = ImageStorageService.shared
    
    init() {
        // Repository will be set when modelContext is available
    }
    
    /// Configure the view model with a model context
    func configure(with modelContext: ModelContext) {
        self.repository = CardRepository(modelContext: modelContext)
        loadCards()
    }
    
    // MARK: - Public Methods
    
    var sortedCards: [Card] {
        let filtered = filteredCards
        switch sortOption {
        case .newest:
            return filtered.sorted { $0.dateScanned > $1.dateScanned }
        case .oldest:
            return filtered.sorted { $0.dateScanned < $1.dateScanned }
        case .favorites:
            return filtered.filter { $0.isFavorite }
        }
    }
    
    private var filteredCards: [Card] {
        // Filter by occasion if selected
        if let occasionFilter = selectedOccasionFilter {
            return cards.filter { $0.occasion == occasionFilter }
        }
        return cards
    }
    
    var availableOccasions: [String] {
        let occasions = cards.compactMap { $0.occasion }
        return Array(Set(occasions)).sorted()
    }
    
    var favoriteCards: [Card] {
        cards.filter { $0.isFavorite }
    }
    
    /// Adds a new card with images
    func addCard(
        frontImage: UIImage?,
        backImage: UIImage?,
        insideLeftImage: UIImage?,
        insideRightImage: UIImage?,
        sender: String? = nil,
        occasion: String? = nil,
        dateReceived: Date? = nil,
        notes: String? = nil
    ) -> Card {
        let cardId = UUID()
        
        // Save images to file system
        let paths: (front: String?, back: String?, insideLeft: String?, insideRight: String?)
        if let repo = repository {
            paths = repo.saveImages(
                frontImage: frontImage,
                backImage: backImage,
                insideLeftImage: insideLeftImage,
                insideRightImage: insideRightImage,
                for: cardId
            )
        } else {
            paths = (front: nil as String?, back: nil as String?, insideLeft: nil as String?, insideRight: nil as String?)
        }
        
        // Create card with file paths
        let card = Card(
            id: cardId,
            frontImagePath: paths.front,
            backImagePath: paths.back,
            insideLeftImagePath: paths.insideLeft,
            insideRightImagePath: paths.insideRight,
            dateScanned: Date(),
            isFavorite: false,
            sender: sender,
            occasion: occasion,
            dateReceived: dateReceived,
            notes: notes
        )
        
        repository?.addCard(card)
        cards.insert(card, at: 0) // Add to beginning for newest first
        
        return card
    }
    
    func deleteCard(_ card: Card) {
        repository?.deleteCard(card)
        cards.removeAll { $0.id == card.id }
    }
    
    func updateCard(_ card: Card) {
        repository?.updateCard()
        // SwiftData tracks changes automatically, just refresh local array
        if let index = cards.firstIndex(where: { $0.id == card.id }) {
            cards[index] = card
        }
    }
    
    func toggleFavorite(for card: Card) {
        card.isFavorite.toggle()
        repository?.updateCard()
        objectWillChange.send()
    }
    
    /// Clears all data (for testing/reset)
    func clearAllData() {
        repository?.clearAllData()
        cards.removeAll()
    }
    
    // MARK: - Private Methods
    
    func loadCards() {
        cards = repository?.fetchAllCards() ?? []
    }
}
